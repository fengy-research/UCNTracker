/* gtkbuildable.c
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


#include "config.h"
#include "gtkbuildable.h"
#include "nls.h"

GType
ucn_buildable_get_type (void)
{
  static GType buildable_type = 0;

  if (!buildable_type)
    buildable_type =
      g_type_register_static_simple (G_TYPE_INTERFACE, I_("UCNBuildable"),
				     sizeof (UCNBuildableIface),
				     NULL, 0, NULL, 0);

  return buildable_type;
}

/**
 * ucn_buildable_set_name:
 * @buildable: a #UCNBuildable
 * @name: name to set
 *
 * Sets the name of the @buildable object.
 *
 * Since: 2.12
 **/
void
ucn_buildable_set_name (UCNBuildable *buildable,
                        const gchar  *name)
{
  UCNBuildableIface *iface;

  g_return_if_fail (UCN_IS_BUILDABLE (buildable));
  g_return_if_fail (name != NULL);

  iface = UCN_BUILDABLE_GET_IFACE (buildable);

  if (iface->set_name)
    (* iface->set_name) (buildable, name);
  else
    g_object_set_data_full (G_OBJECT (buildable),
			    "ucn-builder-name",
			    g_strdup (name),
			    g_free);
}

/**
 * ucn_buildable_get_name:
 * @buildable: a #UCNBuildable
 *
 * Gets the name of the @buildable object. 
 * 
 * #UCNBuilder sets the name based on the the 
 * <link linkend="BUILDER-UI">UCNBuilder UI definition</link> 
 * used to construct the @buildable.
 *
 * Returns: the name set with ucn_buildable_set_name()
 *
 * Since: 2.12
 **/
const gchar *
ucn_buildable_get_name (UCNBuildable *buildable)
{
  UCNBuildableIface *iface;

  g_return_val_if_fail (UCN_IS_BUILDABLE (buildable), NULL);

  iface = UCN_BUILDABLE_GET_IFACE (buildable);

  if (iface->get_name)
    return (* iface->get_name) (buildable);
  else
    return (const gchar*)g_object_get_data (G_OBJECT (buildable),
					    "ucn-builder-name");
}

/**
 * ucn_buildable_add_child:
 * @buildable: a #UCNBuildable
 * @builder: a #UCNBuilder
 * @child: child to add
 * @type: kind of child or %NULL
 *
 * Adds a child to @buildable. @type is an optional string
 * describing how the child should be added.
 *
 * Since: 2.12
 **/
void
ucn_buildable_add_child (UCNBuildable *buildable,
			 UCNBuilder   *builder,
			 GObject      *child,
			 const gchar  *type)
{
  UCNBuildableIface *iface;

  g_return_if_fail (UCN_IS_BUILDABLE (buildable));
  g_return_if_fail (UCN_IS_BUILDER (builder));

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  g_return_if_fail (iface->add_child != NULL);

  (* iface->add_child) (buildable, builder, child, type);
}

/**
 * ucn_buildable_set_buildable_property:
 * @buildable: a #UCNBuildable
 * @builder: a #UCNBuilder
 * @name: name of property
 * @value: value of property
 *
 * Sets the property name @name to @value on the @buildable object.
 *
 * Since: 2.12
 **/
void
ucn_buildable_set_buildable_property (UCNBuildable *buildable,
				      UCNBuilder   *builder,
				      const gchar  *name,
				      const GValue *value)
{
  UCNBuildableIface *iface;

  g_return_if_fail (UCN_IS_BUILDABLE (buildable));
  g_return_if_fail (UCN_IS_BUILDER (builder));
  g_return_if_fail (name != NULL);
  g_return_if_fail (value != NULL);

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  if (iface->set_buildable_property)
    (* iface->set_buildable_property) (buildable, builder, name, value);
  else
    g_object_set_property (G_OBJECT (buildable), name, value);
}

/**
 * ucn_buildable_parser_finished:
 * @buildable: a #UCNBuildable
 * @builder: a #UCNBuilder
 *
 * Called when the builder finishes the parsing of a 
 * <link linkend="BUILDER-UI">UCNBuilder UI definition</link>. 
 * Note that this will be called once for each time 
 * ucn_builder_add_from_file() or ucn_builder_add_from_string() 
 * is called on a builder.
 *
 * Since: 2.12
 **/
void
ucn_buildable_parser_finished (UCNBuildable *buildable,
			       UCNBuilder   *builder)
{
  UCNBuildableIface *iface;

  g_return_if_fail (UCN_IS_BUILDABLE (buildable));
  g_return_if_fail (UCN_IS_BUILDER (builder));

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  if (iface->parser_finished)
    (* iface->parser_finished) (buildable, builder);
}

/**
 * ucn_buildable_construct_child:
 * @buildable: A #UCNBuildable
 * @builder: #UCNBuilder used to construct this object
 * @name: name of child to construct
 *
 * Constructs a child of @buildable with the name @name. 
 *
 * #UCNBuilder calls this function if a "constructor" has been
 * specified in the UI definition.
 *
 * Returns: the constructed child
 *
 * Since: 2.12
 **/
GObject *
ucn_buildable_construct_child (UCNBuildable *buildable,
                               UCNBuilder   *builder,
                               const gchar  *name)
{
  UCNBuildableIface *iface;

  g_return_val_if_fail (UCN_IS_BUILDABLE (buildable), NULL);
  g_return_val_if_fail (UCN_IS_BUILDER (builder), NULL);
  g_return_val_if_fail (name != NULL, NULL);

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  g_return_val_if_fail (iface->construct_child != NULL, NULL);

  return (* iface->construct_child) (buildable, builder, name);
}

/**
 * ucn_buildable_custom_tag_start:
 * @buildable: a #UCNBuildable
 * @builder: a #UCNBuilder used to construct this object
 * @child: child object or %NULL for non-child tags
 * @tagname: name of tag
 * @parser: a #GMarkupParser structure to fill in
 * @data: return location for user data that will be passed in 
 *   to parser functions
 *
 * This is called for each unknown element under &lt;child&gt;.
 * 
 * Returns: %TRUE if a object has a custom implementation, %FALSE
 *          if it doesn't.
 *
 * Since: 2.12
 **/
gboolean
ucn_buildable_custom_tag_start (UCNBuildable  *buildable,
                                UCNBuilder    *builder,
                                GObject       *child,
                                const gchar   *tagname,
                                GMarkupParser *parser,
                                gpointer      *data)
{
  UCNBuildableIface *iface;

  g_return_val_if_fail (UCN_IS_BUILDABLE (buildable), FALSE);
  g_return_val_if_fail (UCN_IS_BUILDER (builder), FALSE);
  g_return_val_if_fail (tagname != NULL, FALSE);

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  g_return_val_if_fail (iface->custom_tag_start != NULL, FALSE);

  return (* iface->custom_tag_start) (buildable, builder, child,
                                      tagname, parser, data);
}

/**
 * ucn_buildable_custom_tag_end:
 * @buildable: A #UCNBuildable
 * @builder: #UCNBuilder used to construct this object
 * @child: child object or %NULL for non-child tags
 * @tagname: name of tag
 * @data: user data that will be passed in to parser functions
 *
 * This is called at the end of each custom element handled by 
 * the buildable.
 *
 * Since: 2.12
 **/
void
ucn_buildable_custom_tag_end (UCNBuildable  *buildable,
                              UCNBuilder    *builder,
                              GObject       *child,
                              const gchar   *tagname,
                              gpointer      *data)
{
  UCNBuildableIface *iface;

  g_return_if_fail (UCN_IS_BUILDABLE (buildable));
  g_return_if_fail (UCN_IS_BUILDER (builder));
  g_return_if_fail (tagname != NULL);

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  if (iface->custom_tag_end)
    (* iface->custom_tag_end) (buildable, builder, child, tagname, data);
}

/**
 * ucn_buildable_custom_finished:
 * @buildable: a #UCNBuildable
 * @builder: a #UCNBuilder
 * @child: child object or %NULL for non-child tags
 * @tagname: the name of the tag
 * @data: user data created in custom_tag_start
 *
 * This is similar to ucn_buildable_parser_finished() but is
 * called once for each custom tag handled by the @buildable.
 * 
 * Since: 2.12
 **/
void
ucn_buildable_custom_finished (UCNBuildable  *buildable,
			       UCNBuilder    *builder,
			       GObject       *child,
			       const gchar   *tagname,
			       gpointer       data)
{
  UCNBuildableIface *iface;

  g_return_if_fail (UCN_IS_BUILDABLE (buildable));
  g_return_if_fail (UCN_IS_BUILDER (builder));

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  if (iface->custom_finished)
    (* iface->custom_finished) (buildable, builder, child, tagname, data);
}

/**
 * ucn_buildable_get_internal_child:
 * @buildable: a #UCNBuildable
 * @builder: a #UCNBuilder
 * @childname: name of child
 *
 * Get the internal child called @childname of the @buildable object.
 *
 * Returns: the internal child of the buildable object 
 *
 * Since: 2.12
 **/
GObject *
ucn_buildable_get_internal_child (UCNBuildable *buildable,
                                  UCNBuilder   *builder,
                                  const gchar  *childname)
{
  UCNBuildableIface *iface;

  g_return_val_if_fail (UCN_IS_BUILDABLE (buildable), NULL);
  g_return_val_if_fail (UCN_IS_BUILDER (builder), NULL);
  g_return_val_if_fail (childname != NULL, NULL);

  iface = UCN_BUILDABLE_GET_IFACE (buildable);
  if (!iface->get_internal_child)
    return NULL;

  return (* iface->get_internal_child) (buildable, builder, childname);
}
