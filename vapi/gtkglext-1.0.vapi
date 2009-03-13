/* gtkglext-1.0.vapi
 *
 * Copyright (C) 2008  Matias De la Puente
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Matias De la Puente <mfpuente.ar@gmail.com>
 */

[CCode (lower_case_cprefix="gdk_gl_", cheader_filename="gtkglext-1.0/gdk/gdkgl.h")]
namespace Gdk.GL
{
	[CCode (cprefix="GDK_GL_")]
	public enum ConfigAttrib
	{
		USE_GL,
		BUFFER_SIZE,
		LEVEL,
		RGBA,
		DOUBLEBUFFER,
		STEREO,
		AUX_BUFFERS,
		RED_SIZE,
		GREEN_SIZE,
		BLUE_SIZE,
		ALPHA_SIZE,
		DEPTH_SIZE,
		STENCIL_SIZE,
		ACCUM_RED_SIZE,
		ACCUM_GREEN_SIZE,
		ACCUM_BLUE_SIZE,
		ACCUM_ALPHA_SIZE,
		CONFIG_CAVEAT,
		X_VISUAL_TYPE,
		TRANSPARENT_TYPE,
		TRANSPARENT_INDEX_VALUE,
		TRANSPARENT_RED_VALUE,
		TRANSPARENT_GREEN_VALUE,
		TRANSPARENT_BLUE_VALUE,
		TRANSPARENT_ALPHA_VALUE,
		DRAWABLE_TYPE,
		RENDER_TYPE,
		X_RENDERABLE,
		FBCONFIG_ID,
		MAX_PBUFFER_WIDTH,
		MAX_PBUFFER_HEIGHT,
		MAX_PBUFFER_PIXELS,
		VISUAL_ID,
		SCREEN,
		SAMPLE_BUFFERS,
		SAMPLES
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum ConfigCaveat
	{
		CONFIG_CAVEAT_DONT_CARE,
		CONFIG_CAVEAT_NONE,
		SLOW_CONFIG,
		NON_CONFORMANT_CONFIG
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum VisualType
	{
		VISUAL_TYPE_DONT_CARE,
		TRUE_COLOR,
		DIRECT_COLOR,
		PSEUDO_COLOR,
		STATIC_COLOR,
		GRAY_SCALE,
		STATIC_GRAY
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum TransparentType
	{
		TRANSPARENT_NONE,
		TRANSPARENT_RGB,
		TRANSPARENT_INDEX
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum DrawableTypeMask
	{
		WINDOW_BIT,
		PIXMAP_BIT,
		PBUFFER_BIT
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum RenderTypeMask
	{
		RGBA_BIT,
		COLOR_INDEX_BIT
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum BufferMask
	{
		FRONT_LEFT_BUFFER_BIT,
		FRONT_RIGHT_BUFFER_BIT,
		BACK_LEFT_BUFFER_BIT,
		BACK_RIGHT_BUFFER_BIT,
		AUX_BUFFERS_BIT,
		DEPTH_BUFFER_BIT,
		STENCIL_BUFFER_BIT,
		ACCUM_BUFFER_BIT
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum ConfigError
	{
		BAD_SCREEN,
		BAD_ATTRIBUTE,
		NO_EXTENSION,
		BAD_VISUAL,
		BAD_CONTEXT,
		BAD_VALUE,
		BAD_ENUM
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum RenderType
	{
		RGBA_TYPE,
		COLOR_INDEX_TYPE
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum DrawableAttrib
	{
		PRESERVED_CONTENTS,
		LARGEST_PBUFFER,
		WIDTH,
		HEIGHT,
		EVENT_MASK
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum PbufferAttrib
	{
		PBUFFER_PRESERVED_CONTENTS,
		PBUFFER_LARGEST_PBUFFER,
		PBUFFER_HEIGHT,
		PBUFFER_WIDTH
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum EventMask
	{
		PBUFFER_CLOBBER_MASK
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum EventType
	{
		DAMAGED,
		SAVED
	}
	
	[CCode (cprefix="GDK_GL_")]
	public enum DrawableType
	{
		WINDOW,
		PBUFFER
	}
	
	[CCode (cprefix="GDK_GL_MODE_")]
	public enum ConfigMode
	{
		RGB,
		RGBA,
		INDEX,
		SINGLE,
		DOUBLE,
		STEREO,
		ALPHA,
		DEPTH,
		STENCIL,
		ACCUM,
		MULTISAMPLE
	}
	
	public static const uint SUCCESS;
	public static const uint ATTRIB_LIST_NONE;
	public static const uint DONT_CARE;
	public static const uint NONE;
	
	[CCode (cname="GdkGLProc")]
	public static delegate void Proc ();
	
	public static void init ([CCode (array_length_pos = 0.9)] ref weak string[] argv);
	public static bool init_check ([CCode (array_length_pos = 0.9)] ref weak string[] argv);
	public static bool parse_args ([CCode (array_length_pos = 0.9)] ref weak string[] argv);
	public static bool query_extension ();
	public static bool query_extension_for_display (Gdk.Display display);
	public static bool query_version (out int major, out int minor);
	public static bool query_version_for_display (Gdk.Display display, out int major, out int minor);
	public static bool query_gl_extension (string extension);
	public static Proc get_proc_address (string proc_name);
	public static weak Pango.Font font_use_pango_font (Pango.FontDescription font_desc, int first, int count, int list_base);
	public static weak Pango.Font font_use_pango_font_for_display (Gdk.Display display, Pango.FontDescription font_desc, int first, int count, int list_base);
		
	[CCode (lower_case_cprefix="gdk_gl_draw_")]
	namespace Draw
	{
		public static void cube (bool solid, double size);
		public static void sphere (bool solid, double radius, int slices, int stacks);
		public static void cone (bool solid, double @base, double height, int slices, int stacks);
		public static void torus (bool solid, double inner_radius, double outer_radius, int nsides, int rings);
		public static void tetrahedron  (bool solid);
		public static void octahedron (bool solid);
		public static void dodecahedron (bool solid);
		public static void icosahedron (bool solid);
		public static void teapot (bool solid, double scale);
	}

	public class Config : GLib.Object
	{
		public Config ([CCode (array_length = false)] int[] attrib_list);
		public Config.for_screen (Gdk.Screen screen, [CCode (array_length = false)] int[] attib_list);
		public Config.by_mode (ConfigMode mode);
		public Config.by_mode_for_screen (Gdk.Screen screen, ConfigMode mode);
		public weak Gdk.Screen get_screen ();
		public bool get_attrib (int attribute, out int @value);
		public weak Gdk.Colormap get_colormap ();
		public weak Gdk.Visual get_visual ();
		public int get_depth ();
		public int get_layer_plane ();
		public int get_n_aux_buffers ();
		public int get_n_sample_buffers ();
		public bool is_rgba ();
		public bool is_double_buffered ();
		public bool is_stereo ();
		public bool has_alpha ();
		public bool has_depth_buffer ();
		public bool has_stencil_buffer ();
		public bool has_accum_buffer ();
	}
		
	public class Context : GLib.Object
	{
		public Context (Gdk.GL.Drawable gldrawable, Gdk.GL.Context share_list, bool direct, int render_type);
		public void destroy ();
		public bool copy (Gdk.GL.Context src, ulong mask);
		public weak Gdk.GL.Drawable get_gl_drawable ();
		public weak Gdk.GL.Config get_gl_config ();
		public weak Gdk.GL.Context get_share_list ();
		public bool is_direct ();
		public int get_render_type ();
		public static weak Gdk.GL.Context get_current ();
	}
		
	public class Drawable : GLib.Object
	{
		public bool make_current (Gdk.GL.Context  glcontext);
		public bool is_double_buffered ();
		public void swap_buffers ();
		public void wait_gl ();
		public void wait_gdk ();
		public bool gl_begin (Gdk.GL.Context glcontext);
		public void gl_end ();
		public weak Gdk.GL.Config get_gl_config ();
		public void get_size (out int width, out int height);
		public static Gdk.GL.Drawable get_current ();
	
		/*public virtual signal Gdk.GL.Context create_new_context (Gdk.GL.Context share_list, bool direct, int render_type);
		public virtual signal bool make_context_current (Gdk.GL.Drawable read, Gdk.GL.Context glcontext);
		public virtual signal bool is_double_buffered ();
		public virtual signal void swap_buffers ();
		public virtual signal void wait_gl ();
		public virtual signal void wait_gdk ();
		public virtual signal bool gl_begin (Gdk.GL.Drawable read, Gdk.GL.Context glcontext);
		public virtual signal void gl_end ();
		public virtual signal Gdk.GL.Config  get_gl_config ();
		public virtual signal void get_size (out int width, out int height);
		*/
	}
	
	public class Pixmap : Gdk.Drawable
	{
		public Pixmap (Gdk.GL.Config glconfig, Gdk.Pixmap pixmap, [CCode (array_length = false)] int[] attrib_list);
		public void destroy ();
		public weak Gdk.Pixmap get_pixmap ();
	}
	
	[CCode (lower_case_cprefix="gdk_pixmap_")]
	namespace GdkPixmap
	{
		public static weak Gdk.GL.Pixmap set_gl_capability (Gdk.Pixmap pixmap, Gdk.GL.Config glconfig, [CCode (array_length = false)] int[] attrib_list);
		public static void unset_gl_capability (Gdk.Pixmap pixmap);
		public static bool is_gl_capable (Gdk.Pixmap pixmap);
		public static weak Gdk.GL.Pixmap get_gl_pixmap (Gdk.Pixmap pixmap);
		public static weak Gdk.GL.Drawable get_gl_drawable (Gdk.Pixmap pixmap);
	}
	
	public class Window : Gdk.Drawable
	{
		public Window (Gdk.GL.Config glconfig, Gdk.Window window, [CCode (array_length = false)] int[] attrib_list);
		public void destroy ();
		public weak Gdk.Window get_window ();
	}
	
	[CCode (lower_case_cprefix="gdk_window_")]
	namespace GdkWindow
	{
		public static weak Gdk.GL.Window set_gl_capability (Gdk.Window window, Gdk.GL.Config glconfig, [CCode (array_length = false)] int[] attrib_list);
		public static void unset_gl_capability (Gdk.Window window);
		public static bool is_gl_capable (Gdk.Window window);
		public static weak Gdk.GL.Window get_gl_window (Gdk.Window window);
		public static weak Gdk.GL.Drawable get_gl_drawable (Gdk.Window window);
	}
}

[CCode (lower_case_cprefix="gtk_gl_", cheader_filename="gtkglext-1.0/gtk/gtkgl.h")]
namespace Gtk.GL
{
	public static void init ([CCode (array_length_pos = 0.9)] ref weak string[] argv);
	public static bool init_check ([CCode (array_length_pos = 0.9)] ref weak string[] argv);
	public static bool parse_args ([CCode (array_length_pos = 0.9)] ref weak string[] argv);
	
	[CCode (lower_case_cprefix="gtk_widget_")]
	namespace GtkWidget
	{
		public static bool set_gl_capability (Gtk.Widget widget, Gdk.GL.Config glconfig, Gdk.GL.Context? share_list, bool direct, int render_type);
		public static bool is_gl_capable (Gtk.Widget widget);
		public static weak Gdk.GL.Config get_gl_config (Gtk.Widget widget);
		public static weak Gdk.GL.Context create_gl_context (Gtk.Widget widget, Gdk.GL.Context share_list, bool direct, int render_type);
		public static weak Gdk.GL.Context get_gl_context (Gtk.Widget widget);
		public static weak Gdk.GL.Window  get_gl_window (Gtk.Widget widget);
		public static weak Gdk.GL.Drawable get_gl_drawable (Gtk.Widget widget);
	}
}

