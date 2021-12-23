#ifndef __LEXX_UI_WINDOW_H__
#define __LEXX_UI_WINDOW_H__

#include <gtk/gtk.h>
#include "lexx-ui.h"

G_BEGIN_DECLS

#define LEXX_TYPE_UI_WINDOW (lexx_ui_window_get_type ())

G_DECLARE_FINAL_TYPE (LexxUiWindow, lexx_ui_window, LEXX, UI_WINDOW, GtkApplicationWindow)

GtkWidget *lexx_ui_window_new (LexxUi *app);

G_END_DECLS

#endif /* __LEXX_UI_WINDOW_H__ */