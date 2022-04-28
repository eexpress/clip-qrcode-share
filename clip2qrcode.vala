using Gtk;
using Posix;

public class QRCode : Gtk.Application {

	private Entry input;
	private Image img;
	private Label txt;
	const string fqrcode = "/tmp/qrcode.png";
	const string linkdir = "/tmp/qrcode-link/";
	const string port = "1280";

	public QRCode() {
		Object(application_id : "org.example.clip2qrcode", flags : ApplicationFlags.HANDLES_OPEN);
	}

	protected override void activate() {

		var window = new ApplicationWindow(this);
		string last_clip = "";
		string last_prim = "";
		mkdir(linkdir, 0750);
		chdir(linkdir);
//~ 		try {
//~ 			this.proc = Gio.Subprocess.new(
//~ 				[ 'python3', '-m', 'http.server', port ],
//~ 				Gio.SubprocessFlags.NONE);
//~ 		} catch (e) { Main.notify(e); }

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
			clip.read_text_async.begin(null, (obj, res) => {
				try {
					string text = clip.read_text_async.end(res);
					print("clipboard:"+text+"\n");
					if (text == null || text == "" || text == last_clip) return;

					string[] filearray = text.split("\n");
					foreach (unowned string i in filearray) {
						File file = File.new_for_path(i);
						if(!file.query_exists()) continue;
						File link = File.new_for_path(linkdir + File.new_for_path(i).get_basename());
//~ 						print(link.get_path ()+"\n");	//full-name
//~ 						print(link.get_basename ()+"\n");
						if (link.query_exists ()) continue;
						try {
							link.make_symbolic_link(i);
						} catch (Error e) { warning(e.message); }
					}

//~ 				show(text);
				} catch (Error e) { warning(e.message); }
				return;
			});
			prim.read_text_async.begin(null, (obj, res) => {
				try {
					string text = prim.read_text_async.end(res);
					print("primary:"+text+"\n");
					if (text == null || text == "" || text == last_prim) return;
					show(text);
				} catch (Error e) { warning(e.message); }
				return;
			});
		});
		img.add_controller(gesture);
		pg.add(img);

		txt = new Label("");
		txt.label = "null";
		pg.add(txt);

		window.set_title("Clip 2 QRcode");
		window.set_child(pg);
		window.present();
	}

	private void show(string s) {
		if(s == null){txt.label = "null"; return;}
		input.text = s;
		File file = File.new_for_path (fqrcode);
		try{
			file.delete();
		} catch (Error e) {}
		try{
			GLib.Regex regex = new GLib.Regex ("'");
			s = regex.replace (s, s.length, 0, "⭕'");
			txt.label = s;
		} catch (Error e) {print ("%s", e.message);}
		Posix.system("qrencode '" + s + "' -o " + fqrcode);
		img.set_from_file(fqrcode);
	}

	private string get_lan_ip() {
		Socket udp4;
		string ipv4 = null;
		try {
			udp4 = new Socket(SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
			GLib.assert(udp4 != null);
			udp4.connect(new InetSocketAddress.from_string("192.168.0.1", int.parse(port)));
			ipv4 = udp4.local_address.get_address().to_string();
			udp4.close();
		} catch (Error e) {
//~ 			log("xxxxxxx" + e);
			udp4 = null;
			ipv4 = null;
		}
		return ipv4;
	}

	public static int main(string[] args) {
		var app = new QRCode();
		return app.run(args);
	}

	//~ ⭕ pinfo libqrcodegen-dev
	//~ https://github.com/nayuki/QR-Code-generator
}
