
#ifndef __TEST_H__
#define __TEST_H__

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>

G_BEGIN_DECLS


#define TYPE_MY_OBJECT (my_object_get_type ())
#define MY_OBJECT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_MY_OBJECT, MyObject))
#define MY_OBJECT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_MY_OBJECT, MyObjectClass))
#define IS_MY_OBJECT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_MY_OBJECT))
#define IS_MY_OBJECT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_MY_OBJECT))
#define MY_OBJECT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_MY_OBJECT, MyObjectClass))

typedef struct _MyObject MyObject;
typedef struct _MyObjectClass MyObjectClass;
typedef struct _MyObjectPrivate MyObjectPrivate;

struct _MyObject {
	GObject parent_instance;
	MyObjectPrivate * priv;
	gint prop;
};

struct _MyObjectClass {
	GObjectClass parent_class;
};


MyObject* my_object_construct (GType object_type);
MyObject* my_object_new (void);
MyObject* my_object_get_child (MyObject* self);
void my_object_set_child (MyObject* self, MyObject* value);
GType my_object_get_type (void);
gint _main (char** args, int args_length1);


G_END_DECLS

#endif
