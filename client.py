import tkinter as tk
from tkinter import ttk

class EntryApp:
    def __init__(self, master):
        self.master = master
        master.title("Entry Example")

        self.entries = {}
        self.create_widgets()

    def create_widgets(self):
        # Entry 1 (dropdown)
        self.create_dropdown("Entry 1", ["Choice 1", "Choice 2", "Choice 3", "Choice 4", "Choice 5"], 0)

        # Entry 2 and 3
        self.create_entry("Entry 2", 1)
        self.create_entry("Entry 3", 2)

        # Hyper entry
        self.create_hyper_entry(3)

        # Entry 5
        self.create_entry("Entry 5", 4)

        # Save button
        save_button = ttk.Button(self.master, text="Save", command=self.save_entries)
        save_button.grid(row=5, column=0, columnspan=2, pady=10)

    def create_dropdown(self, label, choices, row):
        ttk.Label(self.master, text=label).grid(row=row, column=0, sticky='e')
        var = tk.StringVar(self.master)
        var.set(choices[0])  # Set default value
        dropdown = ttk.OptionMenu(self.master, var, *choices)
        dropdown.grid(row=row, column=1)
        self.entries[label] = var

    def create_entry(self, label, row):
        ttk.Label(self.master, text=label).grid(row=row, column=0, sticky='e')
        entry = ttk.Entry(self.master)
        entry.grid(row=row, column=1)
        self.entries[label] = entry

    def create_hyper_entry(self, row):
        ttk.Label(self.master, text="Hyper").grid(row=row, column=0, sticky='e')
        subframe = ttk.Frame(self.master)
        subframe.grid(row=row, column=1)

        self.entries["Hyper"] = {}
        for i, sublabel in enumerate(["Subentry 1", "Subentry 2"]):
            ttk.Label(subframe, text=sublabel).grid(row=i, column=0, sticky='e')
            entry = ttk.Entry(subframe)
            entry.grid(row=i, column=1)
            self.entries["Hyper"][sublabel] = entry

    def save_entries(self):
        data = {}
        for key, value in self.entries.items():
            if key == "Hyper":
                data[key] = {subkey: subvalue.get() or "" for subkey, subvalue in value.items()}
            elif isinstance(value, tk.StringVar):
                data[key] = value.get()
            else:
                data[key] = value.get() or ""
        print(data)

def main():
    root = tk.Tk()
    app = EntryApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
