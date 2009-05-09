#include "config.h"
#include <glib.h>
#include <gmodule.h>
#include <errno.h>
#include "valartl.h"

gboolean vala_runtime_builder_resolve_method_internal (
		const gchar * prefix,
		const gchar * name,
		const gchar * method, gpointer* func);
gboolean
vala_runtime_builder_value_from_string (ValaRuntimeBuilder   *builder,
		GParamSpec   *pspec,
		const gchar  *string,
		GValue       *value,
		GError      **error);
gboolean
vala_runtime_builder_value_from_string_type (ValaRuntimeBuilder   *builder,
		GType         type,
		const gchar  *string,
		GValue       *value,
		GError      **error);
gboolean
vala_runtime_builder_enum_from_string (GType         type, 
		const gchar  *string,
		gint         *enum_value,
		GError      **error);
gboolean
vala_runtime_builder_boolean_from_string (const gchar  *string,
		gboolean     *value,
		GError      **error);
gboolean
vala_runtime_builder_flags_from_string (GType         type, 
		const gchar  *string,
		guint        *flags_value,
		GError      **error);
gboolean
vala_runtime_builder_type_from_string(ValaRuntimeBuilder * builder, 
		const gchar  *string,
		GType *type_value,
		GError      **error);

/**
 * vala_runtime_builder_value_from_string:
 * @builder: a #ValaRuntimeBuilder
 * @pspec: the #GParamSpec for the property
 * @string: the string representation of the value
 * @value: the #GValue to store the result in
 * @error: return location for an error, or %NULL
 *
 * This function demarshals a value from a string. This function
 * calls g_value_init() on the @value argument, so it need not be
 * initialised beforehand.
 *
 * This function can handle char, uchar, boolean, int, uint, long,
 * ulong, enum, flags, float, double, string, #GdkColor and
 * #UCNAdjustment type values. Support for #UCNWidget type values is
 * still to come.
 *
 * Returns: %TRUE on success
 *
 * Since: 2.12
 */
gboolean
vala_runtime_builder_value_from_string (ValaRuntimeBuilder   *builder,
		GParamSpec   *pspec,
		const gchar  *string,
		GValue       *value,
		GError      **error)
{
	g_return_val_if_fail (VALA_RUNTIME_IS_BUILDER (builder), FALSE);
	g_return_val_if_fail (G_IS_PARAM_SPEC (pspec), FALSE);
	g_return_val_if_fail (string != NULL, FALSE);
	g_return_val_if_fail (value != NULL, FALSE);
	g_return_val_if_fail (error == NULL || *error == NULL, FALSE);

	/*
	 * gparamspecunichar has the internal type g_type_uint,
	 * so we cannot handle this in the switch, do it separately
	 */
	if (G_IS_PARAM_SPEC_UNICHAR (pspec))
	{
		gunichar c;
		g_value_init (value, G_TYPE_UINT);
		c = g_utf8_get_char_validated (string, strlen (string));
		if (c > 0)
			g_value_set_uint (value, c);
		return TRUE;
	}

	return vala_runtime_builder_value_from_string_type (builder,
			G_PARAM_SPEC_VALUE_TYPE (pspec),
			string, value, error);
}

/**
 * vala_runtime_builder_value_from_string_type:
 * @builder: a #ValaRuntimeBuilder
 * @type: the #GType of the value
 * @string: the string representation of the value
 * @value: the #GValue to store the result in
 * @error: return location for an error, or %NULL
 *
 * Like vala_runtime_builder_value_from_string(), this function demarshals 
 * a value from a string, but takes a #GType instead of #GParamSpec.
 * This function calls g_value_init() on the @value argument, so it 
 * need not be initialised beforehand.
 *
 * Returns: %TRUE on success
 *
 * Since: 2.12
 */
	gboolean
vala_runtime_builder_value_from_string_type (ValaRuntimeBuilder   *builder,
		GType         type,
		const gchar  *string,
		GValue       *value,
		GError      **error)
{
	gboolean ret = TRUE;

	typedef gboolean (*ParseFunc)(const gchar * string,
			gpointer buffer);
	ParseFunc parse_func = NULL;

	g_return_val_if_fail (type != G_TYPE_INVALID, FALSE);
	g_return_val_if_fail (string != NULL, FALSE);
	g_return_val_if_fail (error == NULL || *error == NULL, FALSE);

	g_value_init (value, type);

	if(type == G_TYPE_GTYPE) {
		GType type_value;
		if (!vala_runtime_builder_type_from_string (builder, string, &type_value, error)) {
			ret = FALSE;
		}
		ret = TRUE;
		g_value_set_gtype (value, type_value);
	} else
		switch (G_TYPE_FUNDAMENTAL (type))
		{
			case G_TYPE_CHAR:
				g_value_set_char (value, string[0]);
				break;
			case G_TYPE_UCHAR:
				g_value_set_uchar (value, (guchar)string[0]);
				break;
			case G_TYPE_BOOLEAN:
				{
					gboolean b;

					if (!vala_runtime_builder_boolean_from_string (string, &b, error))
					{
						ret = FALSE;
						break;
					}
					g_value_set_boolean (value, b);
					break;
				}
			case G_TYPE_INT:
			case G_TYPE_LONG:
				{
					long l;
					gchar *endptr;
					errno = 0;
					l = strtol (string, &endptr, 0);
					if (errno || endptr == string)
					{
						g_set_error (error,
								VALA_RUNTIME_BUILDER_ERROR,
								VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
								"Could not parse integer `%s'",
								string);
						ret = FALSE;
						break;
					}
					if (G_VALUE_HOLDS_INT (value))
						g_value_set_int (value, l);
					else
						g_value_set_long (value, l);
					break;
				}
			case G_TYPE_UINT:
			case G_TYPE_ULONG:
				{
					gulong ul;
					gchar *endptr;
					errno = 0;
					ul = strtoul (string, &endptr, 0);
					if (errno || endptr == string)
					{
						g_set_error (error,
								VALA_RUNTIME_BUILDER_ERROR,
								VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
								"Could not parse unsigned integer `%s'",
								string);
						ret = FALSE;
						break;
					}
					if (G_VALUE_HOLDS_UINT (value))
						g_value_set_uint (value, ul);
					else 
						g_value_set_ulong (value, ul);
					break;
				}
			case G_TYPE_ENUM:
				{
					gint enum_value;
					if (!vala_runtime_builder_enum_from_string (type, string, &enum_value, error))
					{
						ret = FALSE;
						break;
					}
					g_value_set_enum (value, enum_value);
					break;
				}
			case G_TYPE_FLAGS:
				{
					guint flags_value;

					if (!vala_runtime_builder_flags_from_string (type, string, &flags_value, error))
					{
						ret = FALSE;
						break;
					}
					g_value_set_flags (value, flags_value);
					break;
				}
			case G_TYPE_FLOAT:
			case G_TYPE_DOUBLE:
				{
					gdouble d;
					gchar *endptr;
					errno = 0;
					d = g_ascii_strtod (string, &endptr);
					if (errno || endptr == string)
					{
						g_set_error (error,
								VALA_RUNTIME_BUILDER_ERROR,
								VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
								"Could not parse double `%s'",
								string);
						ret = FALSE;
						break;
					}
					if (G_VALUE_HOLDS_FLOAT (value))
						g_value_set_float (value, d);
					else
						g_value_set_double (value, d);
					break;
				}
			case G_TYPE_STRING:
				g_value_set_string (value, string);
				break;
			case G_TYPE_BOXED:
				if (vala_runtime_builder_resolve_method_internal(NULL, 
							g_type_name(type),
							"parse", &parse_func)
						&& parse_func) {
					/*suppose no boxed is larger than 64K*/
					gchar buffer[65536] = "\0\0\0\0\0\0\0\0\0\0\0"; 
					if(!parse_func(string, buffer)) {
						g_set_error (error,
								VALA_RUNTIME_BUILDER_ERROR,
								VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
								"Could not parse boxed type `%s': `%s'",
								g_type_name(type), string);
						ret = FALSE;
					} else
						g_value_set_boxed (value, buffer);
				} else
					if (G_VALUE_HOLDS (value, G_TYPE_STRV))
					{
						gchar **vector = g_strsplit (string, "\n", 0);
						g_value_take_boxed (value, vector);
					}
					else
						ret = FALSE;
				break;
			case G_TYPE_OBJECT:
				ret = FALSE;
				break;
			default:
				g_set_error (error,
						VALA_RUNTIME_BUILDER_ERROR,
						VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
						"Unsupported GType `%s'",
						g_type_name (type));
				ret = FALSE;
				break;
		}

	return ret;
}

	gboolean
vala_runtime_builder_enum_from_string (GType         type, 
		const gchar  *string,
		gint         *enum_value,
		GError      **error)
{
	GEnumClass *eclass;
	GEnumValue *ev;
	gchar *endptr;
	gint value;
	gboolean ret;

	g_return_val_if_fail (G_TYPE_IS_ENUM (type), FALSE);
	g_return_val_if_fail (string != NULL, FALSE);

	ret = TRUE;

	value = strtoul (string, &endptr, 0);
	if (endptr != string) /* parsed a number */
		*enum_value = value;
	else
	{
		eclass = g_type_class_ref (type);
		ev = g_enum_get_value_by_name (eclass, string);
		if (!ev)
			ev = g_enum_get_value_by_nick (eclass, string);

		if (ev)
			*enum_value = ev->value;
		else
		{
			g_set_error (error,
					VALA_RUNTIME_BUILDER_ERROR,
					VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
					"Could not parse enum: `%s'",
					string);
			ret = FALSE;
		}

		g_type_class_unref (eclass);
	}

	return ret;
}

	gboolean
vala_runtime_builder_flags_from_string (GType         type, 
		const gchar  *string,
		guint        *flags_value,
		GError      **error)
{
	GFlagsClass *fclass;
	gchar *endptr, *prevptr;
	guint i, j, value;
	gchar *flagstr;
	GFlagsValue *fv;
	const gchar *flag;
	gunichar ch;
	gboolean eos, ret;

	g_return_val_if_fail (G_TYPE_IS_FLAGS (type), FALSE);
	g_return_val_if_fail (string != 0, FALSE);

	ret = TRUE;

	value = strtoul (string, &endptr, 0);
	if (endptr != string) /* parsed a number */
		*flags_value = value;
	else
	{
		fclass = g_type_class_ref (type);

		flagstr = g_strdup (string);
		for (value = i = j = 0; ; i++)
		{

			eos = flagstr[i] == '\0';

			if (!eos && flagstr[i] != '|')
				continue;

			flag = &flagstr[j];
			endptr = &flagstr[i];

			if (!eos)
			{
				flagstr[i++] = '\0';
				j = i;
			}

			/* trim spaces */
			for (;;)
			{
				ch = g_utf8_get_char (flag);
				if (!g_unichar_isspace (ch))
					break;
				flag = g_utf8_next_char (flag);
			}

			while (endptr > flag)
			{
				prevptr = g_utf8_prev_char (endptr);
				ch = g_utf8_get_char (prevptr);
				if (!g_unichar_isspace (ch))
					break;
				endptr = prevptr;
			}

			if (endptr > flag)
			{
				*endptr = '\0';
				fv = g_flags_get_value_by_name (fclass, flag);

				if (!fv)
					fv = g_flags_get_value_by_nick (fclass, flag);

				if (fv)
					value |= fv->value;
				else
				{
					g_set_error (error,
							VALA_RUNTIME_BUILDER_ERROR,
							VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
							"Unknown flag: `%s'",
							flag);
					ret = FALSE;
					break;
				}
			}

			if (eos)
			{
				*flags_value = value;
				break;
			}
		}

		g_free (flagstr);

		g_type_class_unref (fclass);
	}

  return ret;
}

	gboolean
vala_runtime_builder_type_from_string (ValaRuntimeBuilder * builder, 
		const gchar  *string,
		GType *type_value,
		GError      **error)
{
	*type_value = vala_runtime_builder_type_from_name(builder, string, error);
	if(* error != NULL) return FALSE;
	return TRUE;
}
	gboolean
vala_runtime_builder_boolean_from_string (const gchar  *string,
		gboolean     *value,
		GError      **error)
{
	gboolean retval = TRUE;
	int length;

	g_assert (string != NULL);
	length = strlen (string);

	if (length == 0)
		retval = FALSE;
	else if (length == 1)
	{
		gchar c = g_ascii_tolower (string[0]);
		if (c == 'y' || c == 't' || c == '1')
			*value = TRUE;
		else if (c == 'n' || c == 'f' || c == '0')
			*value = FALSE;
		else
			retval = FALSE;
	}
	else
	{
		gchar *lower = g_ascii_strdown (string, length);

		if (strcmp (lower, "yes") == 0 || strcmp (lower, "true") == 0)
			*value = TRUE;
		else if (strcmp (lower, "no") == 0 || strcmp (lower, "false") == 0)
			*value = FALSE;
		else
			retval = FALSE;
		g_free (lower);
	}

	if (!retval)
		g_set_error (error,
				VALA_RUNTIME_BUILDER_ERROR,
				VALA_RUNTIME_BUILDER_ERROR_INVALID_VALUE,
				"could not parse boolean `%s'",
				string);

  return retval;
}

/*
   Try to resolve a symbol

   */
gboolean vala_runtime_builder_resolve_method_internal (
		const gchar * prefix,
		const gchar * name,
		const gchar * method, gpointer* func) {
	static GModule *module = NULL;
	gboolean rt;
	GString *symbol_name = g_string_new ("");
	char c, *symbol;
	int i;

	if (!module)
		module = g_module_open (NULL, 0);

	for (i = 0; prefix && prefix[i] != '\0'; i++) {
		c = prefix[i];
		g_string_append_c (symbol_name, g_ascii_tolower (c));
	}
	if (prefix) {
		g_string_append_c (symbol_name, '_');
	}
	for (i = 0; name[i] != '\0'; i++)
	{
		c = name[i];
		/* skip if uppercase, first or previous is uppercase */
		if ((c == g_ascii_toupper (c) &&
					i > 0 && name[i-1] != g_ascii_toupper (name[i-1])) ||
				(i > 2 && name[i]   == g_ascii_toupper (name[i]) &&
				 name[i-1] == g_ascii_toupper (name[i-1]) &&
				 name[i-2] == g_ascii_toupper (name[i-2])))
			g_string_append_c (symbol_name, '_');
		g_string_append_c (symbol_name, g_ascii_tolower (c));
	}
	g_string_append (symbol_name, "_");
	g_string_append (symbol_name, method);

	symbol = g_string_free (symbol_name, FALSE);
	g_message("symbol = %s", symbol);
	rt = g_module_symbol (module, symbol, func);

	g_free (symbol);

  return rt;

}
