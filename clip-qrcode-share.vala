//~ 1. I use Adw.Application, but the Window **title** is not Adw.Window, so no Adw dark theme.
//~ 2. I can not shrink the window size after window/entry/label become very wide. L191-197 is my test code.
//~ 	step here:
//~ 	select long text, click window to create QRCode, the window becomes wider.
//~ 	select short text, click window, I want the window size shrink to fit the short label.
//~ 3. when exit, I got `(clip-qrcode-share:7927): GLib-GIO-CRITICAL **: 05:32:29.043: GApplication subclass 'QRCode' failed to chain up on ::shutdown (from end of override function)`

using Gtk;
using Posix;
//~ using Qrencode;	// depend libqrencode-dev
//~ https://github.com/bcedu/ValaSimpleHTTPServer
//~ 分离头指针状态。
//~ ⭕ git reset --hard d87c089
//~ ⭕ git pull
//~ 更新 d87c089..9a7e1d7
//~ Fast-forward

//~ error: Package `libqrencode' not found in specified Vala API directories or GObject-Introspection GIR directories
//~ ⭕ cd /usr/share/vala-0.56/vapi/
//~ ⭕ sudo ln -sf ~/project/clip-qrcode-share/libqrencode.vapi .

public class QRCode : Adw.Application {
	//~ clang-format 老截断 public private 成单行，还把 `=>` 搞成 `=>`（JS中正常)，没法强制成 csharp。
	//~ ⭕ clang-format -style=file -assume-filename=xx.cs -i clip-qrcode-share.vala 也无效。

	private	Entry input;
	private	Image img;
	private	Label txt;
	private ApplicationWindow win;
	const string pngfile = "/tmp/qrcode.png";
	const string linkdir = "/tmp/qrcode.lnk/";
	const string port	 = "12800";

	public QRCode() {
		Object(application_id : "org.eexpss.clip2qrcode", flags : ApplicationFlags.HANDLES_OPEN);
	}

	protected override void activate() {

//~ 		var win = new ApplicationWindow(this);
		win = new ApplicationWindow(this);	// Not adw window. No theme?
		string last_clip = "";
		string last_prim = "";
		mkdir(linkdir, 0750);
		chdir(linkdir);
		string ipadd = get_lan_ip();
		string logopng = get_logo_png();

		// Posix.system("python3 -m http.server " + port + "&");  // 退出时正常杀死
		Posix.system(@"droopy -d $(linkdir) $(logopng) -m \"上传文件到<br>$(linkdir)\" --dl $(port) &");  // 退出时没杀死

		var pg = new Adw.PreferencesGroup();
		pg.set_margin_top(15);
		pg.set_margin_bottom(15);
		pg.set_margin_start(15);
		pg.set_margin_end(15);
		var clip = Gdk.Display.get_default().get_clipboard();
		var prim = Gdk.Display.get_default().get_primary_clipboard();

		input					  = new Entry();
		input.primary_icon_name	  = "edit-clear-all-symbolic";
		input.secondary_icon_name = "folder-saved-search-symbolic";
		input.icon_release.connect((pos) => {
			if (pos == EntryIconPosition.PRIMARY) {
				input.text = "";
			}
			if (pos == EntryIconPosition.SECONDARY) {
				string s = input.text;
				show(s);
			}
		});
		input.text = "version 0.2";
		pg.add(input);

		img = new Image();
		img.set_from_icon_name("edit-find-symbolic");
		img.pixel_size = 280;
		var gesture	   = new Gtk.GestureClick();
		gesture.released.connect((n_press, x, y) => {
			if (clip.formats.contain_gtype(typeof(string))) {
				clip.read_text_async.begin(
					null, (obj, res) => {
						try {
							string text = clip.read_text_async.end(res);
							if (text == null || text == "" || text == last_clip) return;
							last_clip = text;

							bool has_file	   = false;
							string[] filearray = text.split("\n");
							foreach (unowned string i in filearray) {
								File file = File.new_for_path(i);
								if (!file.query_exists()) continue;
								File link = File.new_for_path(linkdir + File.new_for_path(i).get_basename());
								if (link.query_exists()) continue;
								has_file = true;
								try {
									link.make_symbolic_link(i);
								} catch (Error e) { warning(e.message); }
							}
							if (!has_file) return;
							if (ipadd != null) {
								show(@"http://$(ipadd):$(port)/");	// ricotz
							} else {
								img.set_from_icon_name("webpage-symbolic");
							}
						} catch (Error e) { warning(e.message); }
						return;
					});
			}
			if (prim.formats.contain_gtype(typeof(string))) {  // Nahuel
				prim.read_text_async.begin(
					null, (obj, res) => {
						try {
							string text = prim.read_text_async.end(res);
							if (text == null || text == "" || text == last_prim) return;
							last_prim = text;
							show(text);
						} catch (Error e) { warning(e.message); }
						return;
					});
			}
		});
		img.add_controller(gesture);
		pg.add(img);

		txt		  = new Label("");
		txt.label = "null";
		pg.add(txt);

		win.set_title("Clip QRcode Share");
		win.set_child(pg);
		win.resizable = true;
//~ 		win.default_width = 300;
		// Gtk4 常规没有 above 了。只 GJS 提供 Meta.win 有这功能。
//~ 		win.move(0,0);
//~ 		win.set_position (WindowPosition.NONE);
		//~ 		win.make_above();

		win.present();
	}

	protected override void shutdown() {		// 从 GLib.Application 继承的，应该是对应 activate
		try {
			GLib.Dir dir  = GLib.Dir.open(linkdir, 0);
			string ? name = null;
			while ((name = dir.read_name()) != null) {
				File file = File.new_for_path(name);
				file.delete();
			}
			rmdir(linkdir);
			File file = File.new_for_path(pngfile);
			file.delete();
		} catch (Error e) { }
		Posix.system("pkill droopy");
	}

	private void show(string s) {
		if (s == null) {
			txt.label = "null";
			return;
		}
//~ 		print("show:" + s + "\n");
		txt.label  = s;
		File file  = File.new_for_path(pngfile);
		try {
			file.delete();
		} catch (Error e) { }

// 直接修改s会导致溢出。需使用新变量 str。
		string str = s.replace("\\","\\\\").replace("\$","\\\$").replace("\"", "\\\"").replace("`", "\\`");
//~ lwildberg: 反引号 ` 对于 vala 不需要转义。
//~ 但是为了避免被 shell 当成执行语句，在 shell 需要转义。所以只添加一个反斜杠 \\ 。
//~ error: invalid escape sequence ---> replace("\`", "\\\`")
		input.text = str;
		Posix.system(@"qrencode \"$(str)\" -o $(pngfile)");	//depend qrencode + libqrencode4 + libpng16-16
//~ 		var qrcode = new QRcode.encodeString(str, 0, EcLevel.H, Mode.B8, 1);	//depend libqrencode4
//~ 		if (qrcode != null) {
//~ 			for (int iy = 0; iy < qrcode.width; iy++) {
//~ 				for (int ix = 0; ix < qrcode.width; ix++) {
//~ 					if ((qrcode.data[iy * qrcode.width + ix] & 1) != 0) {
//~ 						print("██");	//\u2588\u2588 full block
//~ 					}else{
//~ 						print("  ");
//~ 					}
//~ 				}
//~ 				print("\n");
//~ 			}
//~ 		}
// 单引号包裹字符串时，转义也失效，所以不能再包含单引号。由此只能使用双引号包裹字符串。
		img.set_from_file(pngfile);
//~ 		input.set_size_request(img.pixel_size + 20, -1);
//~ 		input.width_request = img.pixel_size + 20;
//~ 		pg.width_request = img.pixel_size + 20;	// 280 + 20 反正无效？？？？
//~ 		win.width_request = img.pixel_size + 40;	// 280 + 20 反正无效？？？？
		input.queue_resize();
		txt.queue_resize();
		win.queue_resize();
	}

	private string get_logo_png() {
		string[] logo = {"/usr/share/plymouth/ubuntu-logo.png", "/usr/share/pixmaps/fedora-logo.png"};
		foreach (string s in logo) {
			File file = File.new_for_path (s);
			if(file.query_exists ()){return @"-p $(s)";}
		}
		return "";
	}

	private string get_lan_ip() {
		Socket udp4;
		string ipv4 = null;
		try {
			udp4 = new Socket(SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
			GLib.assert(udp4 != null);
			udp4.connect(new InetSocketAddress.from_string("192.168.0.1", int.parse(port)));
			ipv4 = ((InetSocketAddress)udp4.local_address).address.to_string();
			//~ lwildberg: InetSocketAddress is derived from SocketAddress and adds the address property.
			udp4.close();
		} catch (Error e) {
			//~ 如果错写成 `catch (e)`, ninja 会吊死在后台。
			udp4 = null;
			ipv4 = null;
		}
		return ipv4;
	}

	static bool check_app(string app) {
	// 设置为 static，才能在未实例化前，内部调用
		string r = Environment.find_program_in_path(app);
		if (r == null) {
			//~ 			Main.notify(_(`Need install ${cmd} command.`));
			print(@"Need install $(app) command.");
			return false;
		}
		return true;
	}

	public static int main(string[] args) {
		if(! check_app("qrencode")) return 0;
		if(! check_app("droopy")) return 0;

		var app = new QRCode();
		return app.run(args);
	}
	// 添加库编译后，仍需要安装运行库。算了，不折腾。
	//~ ⭕ pinfo libqrcodegen-dev
	//~ https://github.com/nayuki/QR-Code-generator
}
