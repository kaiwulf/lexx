#include "lexx-ui.h"
#include "lexx-ui-window.h"

struct _LexxUi {
  GtkApplication parent_instance;

  GtkWidget *window;
};

struct _LexxUiClass {
  GtkApplicationClass parent_class;
};

G_DEFINE_TYPE (LexxUi, lexx_ui, GTK_TYPE_APPLICATION)

static void quit_activated (GSimpleAction *action, GVariant *parameter, gpointer app) {
  g_application_quit (G_APPLICATION (app));
}

static GActionEntry app_entries[] =
{
  { "quit", quit_activated, NULL, NULL, NULL }
};

static void lexx_ui_startup (GApplication *app) {
  GtkBuilder *builder;
  GMenuModel *app_menu;

  G_APPLICATION_CLASS (lexx_ui_parent_class)->startup (app);

  g_action_map_add_action_entries (G_ACTION_MAP (app),
                                   app_entries, G_N_ELEMENTS (app_entries),
                                   app);

  builder = gtk_builder_new_from_resource ("/ui/frontend/lexx/lexx-ui-menu.ui");
  app_menu = G_MENU_MODEL (gtk_builder_get_object (builder, "appmenu"));
  gtk_application_set_app_menu (GTK_APPLICATION (app), app_menu);
  g_object_unref (builder);
}

static void lexx_ui_activate (GApplication *app) {
  LexxUi *self = LEXX_UI (app);

  if (self->window == NULL)
    self->window = lexx_ui_window_new (LEXX_UI (app));

  gtk_window_present (GTK_WINDOW (self->window));
}


static void lexx_ui_class_init (LexxUiClass *klass) {
  GApplicationClass *app_class = G_APPLICATION_CLASS (klass);

  app_class->startup = lexx_ui_startup;
  app_class->activate = lexx_ui_activate;
}

static void lexx_ui_init (LexxUi *self)
{
}

GtkApplication *lexx_ui_new (void) {
  return g_object_new (lexx_ui_get_type (), "application-id", "ui.lexx", NULL);
}