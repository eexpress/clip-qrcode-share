using Gtk;
using Posix;

public class QRCode : Gtk.Application {

	private Entry input;
	const string fqrcode = "/tmp/qrcode.png";

	public QRCode() {
		Object(application_id : "org.example.clip2qrcode", flags : ApplicationFlags.HANDLES_OPEN);
	}

	protected override void activate() {

		var window = new ApplicationWindow(this);
		string last_clip = "";
		string last_prim = "";

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
		});
		pg.add(input);

		var img = new Image();
		img.set_from_icon_name("edit-find-symbolic");
		img.pixel_size = 280;
		var gesture = new Gtk.GestureClick();
		gesture.released.connect((n_press, x, y) => {
			clip.read_text_async.begin(null, (obj, res) => {
					try {
						string s = clip.read_text_async.end(res);
						if (s == last_clip) return;
						show(s);
					} catch (Error e) {
						warning(e.message);
					}
				});
			prim.read_text_async.begin(null, (obj, res) => {
					try {
						string s = prim.read_text_async.end(res);
						if (s == last_prim) return;
						show(s);
					} catch (Error e) {
						warning(e.message);
					}
				});
		});
		img.add_controller(gesture);
		pg.add(img);

		var txt = new Label("");
		txt.label = "null";
		pg.add(txt);

		window.set_title("Clip 2 QRcode");
		window.set_child(pg);
		window.present();
	}

	private void show(string s) {
		input.text = s;
		Posix.system("qrencode " + s + " -o " + fqrcode + "&");
		img.set_from_file(fqrcode);
	}

	public static int main(string[] args) {
		var app = new QRCode();
		return app.run(args);
	}

	//~ ⭕ pinfo libqrcodegen-dev
	//~ https://github.com/nayuki/QR-Code-generator
}
