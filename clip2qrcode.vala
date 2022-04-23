public class eexpss {

	public static int main(string[] argv) {
//~ 		Gtk.Entry input;
//~ 		var input = new Gtk.Entry();

		var app = new Gtk.Application("create.meson.build.vala", ApplicationFlags.FLAGS_NONE);

		app.activate.connect(() => {
			var window = new Gtk.ApplicationWindow(app);

			var pg = new Adw.PreferencesGroup();

//~ The name `EntryRow' does not exist in the context of `Adw' (libadwaita-1)
			var input = new Gtk.Entry();
			input.primary_icon_name = "edit-clear-all-symbolic";
			input.secondary_icon_name = "folder-saved-search-symbolic";
			pg.add(input);

			var img = new Gtk.Image();
			img.set_from_icon_name("edit-find-symbolic");
			img.pixel_size = 280;
			var gesture = new Gtk.GestureClick();
			gesture.connect("released", click);
//~ runtime error: g_object_connect: invalid signal spec "released"
//~ 			gesture.connect("released", (n_press, x, y) =>{
//~ 			});
//~ error: lambda expression not allowed in this context
			img.add_controller(gesture);
			pg.add(img);

			window.set_title("Clip 2 QRcode");
			window.set_child(pg);
			window.present();
		});

		return app.run(argv);
	}

	private	void click(int n_press, double x, double y) {
		stdout.printf("clicked.");
//~ 		input.text = "clicked";
//~  error: The name `input' does not exist in the context of `eexpss.click'
		return;
	}
}
