#ifndef __LEXX_UI_H__
#define __LEXX_UI_H__

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define LEXX_TYPE_UI (lexx_ui_get_type ())

G_DECLARE_FINAL_TYPE (LexxUi, lexx_ui, LEXX, UI, GtkApplication)

GtkApplication *lexx_ui_new (void);

G_END_DECLS

#endif /* __LEXX_UI_H__ */