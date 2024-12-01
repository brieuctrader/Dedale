from pathlib import Path


def move_csv_files(source_root, destination_root, folder_name=None):
    source_path = Path(source_root)
    destination_path = Path(destination_root)

    if folder_name is None:
        folder_name = f"backtest_data"

    new_folder = destination_path / folder_name
    new_folder.mkdir(parents=True, exist_ok=True)

    csv_files = list(source_path.rglob('*.csv'))
    number_files = len(csv_files)

    for csv_file in csv_files:
        destination_file_path = new_folder / csv_file.name
        csv_file.rename(destination_file_path)

    if number_files > 0:
        print(
            f"{number_files} fichiers CSV dans {source_root} déplacés vers {destination_root}"
        )
    else:
        print(f"Aucun fichier trouvé dans {source_root}")


if __name__ == "__main__":

    source_root = r""
    destination_root = r""

    move_csv_files(source_root, destination_root)
