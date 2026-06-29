#include <gtk/gtk.h>

typedef struct {
    GtkWidget *text_window;
    GtkWidget *display_window;
    GtkWidget *text_view;
    GtkWidget *display_area;
} AppWindows;

static void activate_cb(GtkApplication *app, gpointer user_data) {
    AppWindows *windows = g_new(AppWindows, 1);
    
    // Create text input window
    windows->text_window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(windows->text_window), "Text Input");
    gtk_window_set_default_size(GTK_WINDOW(windows->text_window), 400, 300);

    // Create display window
    windows->display_window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(windows->display_window), "Display");
    gtk_window_set_default_size(GTK_WINDOW(windows->display_window), 500, 400);

    // Set up text input area
    GtkWidget *text_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_window_set_child(GTK_WINDOW(windows->text_window), text_box);

    // Create scrolled window for text view
    GtkWidget *scrolled_window = gtk_scrolled_window_new();
    gtk_widget_set_vexpand(scrolled_window, TRUE);
    gtk_box_append(GTK_BOX(text_box), scrolled_window);

    // Create text view
    windows->text_view = gtk_text_view_new();
    gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(windows->text_view), GTK_WRAP_WORD_CHAR);
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(scrolled_window), windows->text_view);

    // Create button box
    GtkWidget *button_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 5);
    gtk_box_append(GTK_BOX(text_box), button_box);

    // Create enter button with icon
    GtkWidget *enter_button = gtk_button_new_from_icon_name("go-next");
    gtk_box_append(GTK_BOX(button_box), enter_button);

    // Set up display area
    windows->display_area = gtk_drawing_area_new();
    gtk_window_set_child(GTK_WINDOW(windows->display_window), windows->display_area);

    // Connect button click handler
    g_signal_connect(enter_button, "clicked", G_CALLBACK(on_enter_clicked), windows);

    // Show both windows
    gtk_window_present(GTK_WINDOW(windows->text_window));
    gtk_window_present(GTK_WINDOW(windows->display_window));
}

static void on_enter_clicked(GtkButton *button, gpointer user_data) {
    AppWindows *windows = (AppWindows *)user_data;
    
    // Get text buffer
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(windows->text_view));
    
    // Get start and end iterators
    GtkTextIter start, end;
    gtk_text_buffer_get_bounds(buffer, &start, &end);
    
    // Get text content
    char *text = gtk_text_buffer_get_text(buffer, &start, &end, FALSE);
    
    // Process the text here and update the display area as needed
    // For example, you might want to trigger a redraw:
    gtk_widget_queue_draw(windows->display_area);
    
    g_free(text);
}

int main(int argc, char *argv[]) {
    GtkApplication *app;
    int status;

    app = gtk_application_new("com.example.gtk4app", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate_cb), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}
