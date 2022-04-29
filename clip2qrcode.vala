using Gtk;
using Posix;

public class QRCode : Gtk.Application {

	private Entry input;
	private Image img;
	private Label txt;
	const string pngfile = "/tmp/qrcode.png";
	const string linkdir = "/tmp/qrcode.lnk/";
	const string port = "12800";

	public QRCode() {
		Object(application_id : "org.eexpss.clip2qrcode", flags : ApplicationFlags.HANDLES_OPEN);
	}

	protected override void activate() {

		var window = new ApplicationWindow(this);
		string last_clip = "";
		string last_prim = "";
		mkdir(linkdir, 0750);
		chdir(linkdir);
		string ipadd = get_lan_ip();
		Posix.system("python3 -m http.server " + port + "&");	//auto kill after close

		var pg = new Adw.PreferencesGroup();
		var clip = Gdk.Display.get_default().get_clipboard();
		var prim = Gdk.Display.get_default().get_primary_clipboard();

		input = new Entry();
		input.primary_icon_name = "edit-clear-all-symbolic";
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
		pg.add(input);

		img = new Image();
		img.set_from_icon_name("edit-find-symbolic");
		img.pixel_size = 280;
		var gesture = new Gtk.GestureClick();
		gesture.released.connect((n_press, x, y) => {
			if (clip.formats.contain_gtype (typeof (string))){
				clip.read_text_async.begin(null, (obj, res) => {
					try {
						string text = clip.read_text_async.end(res);
						if (text == null || text == "" || text == last_clip) return;
						last_clip = text;

						bool has_file = false;
						string[] filearray = text.split("\n");
						foreach (unowned string i in filearray) {
							File file = File.new_for_path(i);
							if(!file.query_exists()) continue;
							File link = File.new_for_path(linkdir + File.new_for_path(i).get_basename());
							if (link.query_exists ()) continue;
							has_file = true;
							try {
								link.make_symbolic_link(i);
							} catch (Error e) { warning(e.message); }
						}
						if(!has_file) return;
						if(ipadd != null){
							show(@"http://$(ipadd):$(port)/");	//ricotz
						} else {
							img.set_from_icon_name("webpage-symbolic");
						}
					} catch (Error e) { warning(e.message); }
					return;
				});
			}
			if (prim.formats.contain_gtype (typeof (string))){	//Nahuel
				prim.read_text_async.begin(null, (obj, res) => {
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

		txt = new Label("");
		txt.label = "null";
		pg.add(txt);

		window.set_title("Clip 2 QRcode");
		window.set_child(pg);
//~ 		window.make_above();
//~ 		window.set_keep_above(true);
//~ 		make_above(window);
		window.present();
	}

	protected override void shutdown() {
		try{
			GLib.Dir dir = GLib.Dir.open (linkdir, 0);
			string? name = null;
			while ((name = dir.read_name ()) != null) {
				File file = File.new_for_path (name);
				file.delete();
			}
			rmdir(linkdir);
			File file = File.new_for_path (pngfile);
			file.delete();
		} catch (Error e) {}
//~ 		(clip2qrcode:30550): GLib-GIO-CRITICAL **: 22:25:07.999: GApplication subclass 'QRCode' failed to chain up on ::shutdown (from end of override function)
	}

	private void show(string s) {
		if(s == null){txt.label = "null"; return;}
		print("show:"+s+"\n");
		input.text = s;
		txt.label = s;
		File file = File.new_for_path (pngfile);
		try{
			file.delete();
		} catch (Error e) {}
//~ 		try{	//单引号会导致截断，转义也不对。
//~ 			GLib.Regex regex = new GLib.Regex ("'");
//~ 			s = regex.replace (s, s.length, 0, "⭕'");	//直接修改s会导致溢出。
//~ 			txt.label = s;
//~ 		} catch (Error e) {print ("%s", e.message);}
		Posix.system("qrencode '" + s + "' -o " + pngfile);
		img.set_from_file(pngfile);
	}

	private string get_lan_ip() {
		Socket udp4;
		string ipv4 = null;
		try {
			udp4 = new Socket(SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
			GLib.assert(udp4 != null);
			udp4.connect(new InetSocketAddress.from_string("192.168.0.1", int.parse(port)));
			ipv4 = ((InetSocketAddress) udp4.local_address).address.to_string();
//~ lwildberg: InetSocketAddress is derived from SocketAddress and adds the address property.
			udp4.close();
		} catch (Error e) {
//~ If write as `catch (e)`, ninja will enter a dead loop.
			udp4 = null;
			ipv4 = null;
		}
		return ipv4;
	}

	public static int main(string[] args) {
		const string cmd = "qrencode";
		string r = Environment.find_program_in_path(cmd);
		if (r == null) {
//~ 			Main.notify(_(`Need install ${cmd} command.`));
			print(@"Need install $(cmd) command.");
			return 0;
		}

		var app = new QRCode();
		return app.run(args);
	}

//~ ⭕ pinfo libqrcodegen-dev
//~ https://github.com/nayuki/QR-Code-generator
}
