#include <gtk/gtk.h>
#include "lexx-ui.h"

/*
    Based on the example from: 
    https://github.com/ebassi/glarea-example
*/

int main (int argc, char *argv[]) {
  return g_application_run (G_APPLICATION (lexx_ui_new ()), argc, argv);
}