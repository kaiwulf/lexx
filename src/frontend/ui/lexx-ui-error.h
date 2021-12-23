#ifndef __LEXX_UI_ERROR_H__
#define __LEXX_UI_ERROR_H__

#include <glib.h>

G_BEGIN_DECLS

#define LEXX_UI_ERROR (lexx_ui_error_quark ())

typedef enum {
  LEXX_UI_ERROR_SHADER_COMPILATION,
  LEXX_UI_ERROR_SHADER_LINK
} LexUIError;

GQuark lexx_ui_error_quark (void);

G_END_DECLS

#endif /* __LEXX_UI_ERROR_H__ */
