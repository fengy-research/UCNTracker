using GLib;
using UCNTracker.Geometry;
using UCNTracker.Device;

public int main(string[] args) {
	Part part = new Part();
	part.volume = new Box(Vector(3.0, 4.0, 5.0));

	return 0;
}
