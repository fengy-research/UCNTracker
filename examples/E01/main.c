
#include "main.h"
#include <library/ucntracker.h>
#include <core/experiment.h>
#include <core/part.h>
#include <core/run.h>
#include <core/volume.h>
#include <core/vertex.h>
#include <core/vector.h>
#include <physics/random.h>
#include <physics/ptype.h>
#include <core/track.h>
#include <stdio.h>




UCNBuilder* builder = NULL;
double MFP = 3.0;
gint N_TRACKS = 20000;
static void __lambda0 (UCNExperiment* obj, UCNDeviceRun* run);
static void ___lambda0_ucn_experiment_prepare (UCNExperiment* _sender, UCNDeviceRun* run, gpointer self);
static void __lambda1 (UCNExperiment* obj, UCNDeviceRun* run);
static void ___lambda1_ucn_experiment_finish (UCNExperiment* _sender, UCNDeviceRun* run, gpointer self);
static void __lambda2 (UCNDevicePart* obj, UCNDeviceTrack* track, const UCNDeviceState* leave, const UCNDeviceState* enter, gboolean* transported);
static void ___lambda2_ucn_device_part_transport (UCNDevicePart* _sender, UCNDeviceTrack* track, const UCNDeviceState* s_leave, const UCNDeviceState* s_enter, gboolean* transported, gpointer self);
static void __lambda3 (UCNDevicePart* obj, UCNDeviceTrack* track, const UCNDeviceState* state);
static void ___lambda3_ucn_device_part_hit (UCNDevicePart* _sender, UCNDeviceTrack* track, const UCNDeviceState* next, gpointer self);



static void __lambda0 (UCNExperiment* obj, UCNDeviceRun* run) {
	UCNGeometryVolume* _tmp1;
	GObject* _tmp0;
	UCNGeometryVolume* volume;
	g_return_if_fail (obj != NULL);
	g_return_if_fail (run != NULL);
	_tmp1 = NULL;
	_tmp0 = NULL;
	volume = (_tmp1 = (_tmp0 = ucn_builder_get_object (builder, "cellVolume"), UCN_GEOMETRY_IS_VOLUME (_tmp0) ? ((UCNGeometryVolume*) _tmp0) : NULL), (_tmp1 == NULL) ? NULL : g_object_ref (_tmp1));
	{
		gint i;
		i = 0;
		for (; i < N_TRACKS; i++) {
			UCNDeviceVertex* head;
			UCNGeometryVector _tmp2 = {0};
			UCNGeometryVector v;
			UCNDeviceTrack* track;
			head = ucn_device_vertex_new ();
			head->position = ucn_geometry_volume_sample (volume, TRUE);
			v = (ucn_geometry_vector_init (&_tmp2, 0.0, 0.0, 0.0), _tmp2);
			ucn_random_dir_3d (&v.x, &v.y, &v.z);
			head->velocity = v;
			head->weight = 1.0;
			track = ucn_device_run_add_track (run, ucn_ptype_neutron, head);
			ucn_geometry_vector_mul (&head->velocity, 1.0);
			ucn_device_track_set_vector (track, "in", &head->position);
			(head == NULL) ? NULL : (head = (ucn_device_vertex_unref (head), NULL));
			(track == NULL) ? NULL : (track = (ucn_device_track_unref (track), NULL));
		}
	}
	(volume == NULL) ? NULL : (volume = (g_object_unref (volume), NULL));
}


static void ___lambda0_ucn_experiment_prepare (UCNExperiment* _sender, UCNDeviceRun* run, gpointer self) {
	__lambda0 (_sender, run);
}


static void __lambda1 (UCNExperiment* obj, UCNDeviceRun* run) {
	g_return_if_fail (obj != NULL);
	g_return_if_fail (run != NULL);
	{
		GList* track_collection;
		GList* track_it;
		track_collection = run->tracks;
		for (track_it = track_collection; track_it != NULL; track_it = track_it->next) {
			UCNDeviceTrack* _tmp2;
			UCNDeviceTrack* track;
			_tmp2 = NULL;
			track = (_tmp2 = (UCNDeviceTrack*) track_it->data, (_tmp2 == NULL) ? NULL : ucn_device_track_ref (_tmp2));
			{
				UCNGeometryVector in;
				UCNGeometryVector out;
				char* _tmp1;
				char* _tmp0;
				in = ucn_device_track_get_vector (track, "in");
				out = ucn_device_track_get_vector (track, "out");
				_tmp1 = NULL;
				_tmp0 = NULL;
				fprintf (stdout, "%s %s %lf %lf\n", _tmp0 = ucn_geometry_vector_to_string (&in, "%lf %lf %lf"), _tmp1 = ucn_geometry_vector_to_string (&out, "%lf %lf %lf"), ucn_device_track_get_double (track, "length"), ucn_device_track_get_double (track, "#scatters"));
				_tmp1 = (g_free (_tmp1), NULL);
				_tmp0 = (g_free (_tmp0), NULL);
				(track == NULL) ? NULL : (track = (ucn_device_track_unref (track), NULL));
			}
		}
	}
}


static void ___lambda1_ucn_experiment_finish (UCNExperiment* _sender, UCNDeviceRun* run, gpointer self) {
	__lambda1 (_sender, run);
}


static void __lambda2 (UCNDevicePart* obj, UCNDeviceTrack* track, const UCNDeviceState* leave, const UCNDeviceState* enter, gboolean* transported) {
	g_return_if_fail (obj != NULL);
	g_return_if_fail (track != NULL);
	ucn_device_track_set_vector (track, "out", &(*leave).vertex->position);
}


static void ___lambda2_ucn_device_part_transport (UCNDevicePart* _sender, UCNDeviceTrack* track, const UCNDeviceState* s_leave, const UCNDeviceState* s_enter, gboolean* transported, gpointer self) {
	__lambda2 (_sender, track, s_leave, s_enter, transported);
}


static void __lambda3 (UCNDevicePart* obj, UCNDeviceTrack* track, const UCNDeviceState* state) {
	double length;
	double r;
	gboolean scatter;
	g_return_if_fail (obj != NULL);
	g_return_if_fail (track != NULL);
	/*
	stdout.printf("%lf %lf %lf\n", 
	state.vertex.position.x,
	state.vertex.position.y,
	state.vertex.position.z);
	*/
	length = ucn_device_track_get_double (track, "length");
	r = ucn_random_uniform ();
	scatter = FALSE;
	if (r > exp ((-length) / MFP)) {
		scatter = TRUE;
	}
	length = length + ucn_device_track_estimate_distance (track, &(*state));
	ucn_device_track_set_double (track, "length", length);
	if (scatter) {
		double norm;
		UCNGeometryVector _tmp0 = {0};
		UCNGeometryVector v;
		ucn_device_track_set_double (track, "#scatters", ucn_device_track_get_double (track, "#scatters") + 1.0);
		norm = ucn_geometry_vector_norm (&(*state).vertex->velocity);
		v = (ucn_geometry_vector_init (&_tmp0, 0.0, 0.0, 0.0), _tmp0);
		ucn_random_dir_3d (&v.x, &v.y, &v.z);
		ucn_geometry_vector_mul (&v, norm);
		(*state).vertex->velocity = v;
	}
}


static void ___lambda3_ucn_device_part_hit (UCNDevicePart* _sender, UCNDeviceTrack* track, const UCNDeviceState* next, gpointer self) {
	__lambda3 (_sender, track, next);
}


gint _main (char** args, int args_length1) {
	GError * inner_error;
	UCNBuilder* _tmp0;
	UCNExperiment* _tmp2;
	GObject* _tmp1;
	UCNExperiment* experiment;
	UCNDevicePart* _tmp4;
	GObject* _tmp3;
	UCNDevicePart* cell;
	gint _tmp5;
	inner_error = NULL;
	ucn_init (&args_length1, &args);
	_tmp0 = NULL;
	builder = (_tmp0 = ucn_builder_new (), (builder == NULL) ? NULL : (builder = (g_object_unref (builder), NULL)), _tmp0);
	ucn_builder_add_from_file (builder, "example-01.xml", &inner_error);
	if (inner_error != NULL) {
		g_critical ("file %s: line %d: uncaught error: %s", __FILE__, __LINE__, inner_error->message);
		g_clear_error (&inner_error);
		return 0;
	}
	_tmp2 = NULL;
	_tmp1 = NULL;
	experiment = (_tmp2 = (_tmp1 = ucn_builder_get_object (builder, "experiment"), UCN_IS_EXPERIMENT (_tmp1) ? ((UCNExperiment*) _tmp1) : NULL), (_tmp2 == NULL) ? NULL : g_object_ref (_tmp2));
	_tmp4 = NULL;
	_tmp3 = NULL;
	cell = (_tmp4 = (_tmp3 = ucn_builder_get_object (builder, "cell"), UCN_DEVICE_IS_PART (_tmp3) ? ((UCNDevicePart*) _tmp3) : NULL), (_tmp4 == NULL) ? NULL : g_object_ref (_tmp4));
	g_signal_connect (experiment, "prepare", (GCallback) ___lambda0_ucn_experiment_prepare, NULL);
	g_signal_connect (experiment, "finish", (GCallback) ___lambda1_ucn_experiment_finish, NULL);
	g_signal_connect (cell, "transport", (GCallback) ___lambda2_ucn_device_part_transport, NULL);
	g_signal_connect (cell, "hit", (GCallback) ___lambda3_ucn_device_part_hit, NULL);
	ucn_experiment_run (experiment);
	return (_tmp5 = 0, (experiment == NULL) ? NULL : (experiment = (g_object_unref (experiment), NULL)), (cell == NULL) ? NULL : (cell = (g_object_unref (cell), NULL)), _tmp5);
}


int main (int argc, char ** argv) {
	g_type_init ();
	return _main (argv, argc);
}




