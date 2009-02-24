/* GTK - The GIMP Toolkit
 * Copyright (C) 2006-2007 Async Open Source,
 *                         Johan Dahlin <jdahlin@async.com.br>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef __UCN_BUILDABLE_H__
#define __UCN_BUILDABLE_H__

#include "gtkbuilder.h"

G_BEGIN_DECLS

#define UCN_TYPE_BUILDABLE            (ucn_buildable_get_type ())
#define UCN_BUILDABLE(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), UCN_TYPE_BUILDABLE, UCNBuildable))
#define UCN_BUILDABLE_CLASS(obj)      (G_TYPE_CHECK_CLASS_CAST ((obj), UCN_TYPE_BUILDABLE, UCNBuildableIface))
#define UCN_IS_BUILDABLE(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), UCN_TYPE_BUILDABLE))
#define UCN_BUILDABLE_GET_IFACE(obj)  (G_TYPE_INSTANCE_GET_INTERFACE ((obj), UCN_TYPE_BUILDABLE, UCNBuildableIface))


typedef struct _UCNBuildable      UCNBuildable; /* Dummy typedef */
typedef struct _UCNBuildableIface UCNBuildableIface;

struct _UCNBuildableIface
{
  GTypeInterface g_iface;

  /* virtual table */
  void          (* set_name)               (UCNBuildable  *buildable,
                                            const gchar   *name);
  const gchar * (* get_name)               (UCNBuildable  *buildable);
  void          (* add_child)              (UCNBuildable  *buildable,
					    UCNBuilder    *builder,
					    GObject       *child,
					    const gchar   *type);
  void          (* set_buildable_property) (UCNBuildable  *buildable,
					    UCNBuilder    *builder,
					    const gchar   *name,
					    const GValue  *value);
  GObject *     (* construct_child)        (UCNBuildable  *buildable,
					    UCNBuilder    *builder,
					    const gchar   *name);
  gboolean      (* custom_tag_start)       (UCNBuildable  *buildable,
					    UCNBuilder    *builder,
					    GObject       *child,
					    const gchar   *tagname,
					    GMarkupParser *parser,
					    gpointer      *data);
  void          (* custom_tag_end)         (UCNBuildable  *buildable,
					    UCNBuilder    *builder,
					    GObject       *child,
					    const gchar   *tagname,
					    gpointer      *data);
  void          (* custom_finished)        (UCNBuildable  *buildable,
					    UCNBuilder    *builder,
					    GObject       *child,
					    const gchar   *tagname,
					    gpointer       data);
  void          (* parser_finished)        (UCNBuildable  *buildable,
					    UCNBuilder    *builder);

  GObject *     (* get_internal_child)     (UCNBuildable  *buildable,
					    UCNBuilder    *builder,
					    const gchar   *childname);
};


GType     ucn_buildable_get_type               (void) G_GNUC_CONST;

void      ucn_buildable_set_name               (UCNBuildable        *buildable,
						const gchar         *name);
const gchar * ucn_buildable_get_name           (UCNBuildable        *buildable);
void      ucn_buildable_add_child              (UCNBuildable        *buildable,
						UCNBuilder          *builder,
						GObject             *child,
						const gchar         *type);
void      ucn_buildable_set_buildable_property (UCNBuildable        *buildable,
						UCNBuilder          *builder,
						const gchar         *name,
						const GValue        *value);
GObject * ucn_buildable_construct_child        (UCNBuildable        *buildable,
						UCNBuilder          *builder,
						const gchar         *name);
gboolean  ucn_buildable_custom_tag_start       (UCNBuildable        *buildable,
						UCNBuilder          *builder,
						GObject             *child,
						const gchar         *tagname,
						GMarkupParser       *parser,
						gpointer            *data);
void      ucn_buildable_custom_tag_end         (UCNBuildable        *buildable,
						UCNBuilder          *builder,
						GObject             *child,
						const gchar         *tagname,
						gpointer            *data);
void      ucn_buildable_custom_finished        (UCNBuildable        *buildable,
						UCNBuilder          *builder,
						GObject             *child,
						const gchar         *tagname,
						gpointer             data);
void      ucn_buildable_parser_finished        (UCNBuildable        *buildable,
						UCNBuilder          *builder);
GObject * ucn_buildable_get_internal_child     (UCNBuildable        *buildable,
						UCNBuilder          *builder,
						const gchar         *childname);

G_END_DECLS

#endif /* __UCN_BUILDABLE_H__ */
