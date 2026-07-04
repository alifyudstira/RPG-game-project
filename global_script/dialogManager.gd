# dialog_manager.gd
# Daftarkan sebagai Autoload dengan nama "DialogManager"
extends Node

signal dialogue_updated(node_data: Dictionary)   # kirim node saat ini ke UI
signal options_presented(options: Array)         # kirim daftar opsi ke UI
signal dialogue_ended                            # dialog selesai

var dialogue_data: Array = []
var current_index: int = 0
var is_active: bool = false

# ============================================================
# MULAI DIALOG
# ============================================================
func start_dialogue(json_path: String, start_id: String = "Start") -> void:
	print("[DialogManager] start_dialogue dipanggil, path=", json_path, " start_id=", start_id)
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("DialogManager: gagal buka file %s" % json_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	print("[DialogManager] file berhasil dibaca, panjang teks=", json_text.length())
	
	var parsed = JSON.parse_string(json_text)
	if parsed == null:
		push_error("DialogManager: JSON tidak valid di %s" % json_path)
		return
	
	# JSON kamu dibungkus array luar [ [ ...nodes... ] ]
	dialogue_data = parsed[0] if parsed is Array and parsed.size() > 0 else []
	print("[DialogManager] jumlah node dialog ter-parse: ", dialogue_data.size())
	
	var start_index = _find_index_by_id(start_id)
	if start_index == -1:
		push_error("DialogManager: id '%s' tidak ditemukan" % start_id)
		return
	
	current_index = start_index
	is_active = true
	print("[DialogManager] mulai dari index=", current_index)
	_show_current_node()

# ============================================================
# NAVIGASI
# ============================================================

## Panggil saat player tekan "lanjut" (Enter/Space) di node tanpa opsi
func advance() -> void:
	if not is_active:
		return
	current_index += 1
	if current_index >= dialogue_data.size():
		end_dialogue()
		return
	_show_current_node()

## Panggil saat player memilih salah satu opsi (id tujuan)
func select_option(option_id: String) -> void:
	var idx = _find_index_by_id(option_id)
	if idx == -1:
		push_error("DialogManager: opsi id '%s' tidak ditemukan" % option_id)
		return
	
	# PERBAIKAN: Set ke indeks setelahnya (idx + 1) untuk melewati teks pertanyaan Clyde
	current_index = idx + 1
	
	# Pastikan tidak out of bounds sebelum menampilkan node
	if current_index >= dialogue_data.size():
		end_dialogue()
		return
		
	_show_current_node()

func end_dialogue() -> void:
	is_active = false
	dialogue_data = []
	current_index = 0
	dialogue_ended.emit()

# ============================================================
# INTERNAL
# ============================================================
func _show_current_node() -> void:
	var node: Dictionary = dialogue_data[current_index]
	dialogue_updated.emit(node)
	
	if node.has("options"):
		print("[DialogManager] node punya options, emit options_presented")
		options_presented.emit(node["options"])
	elif node.has("function"):
		print("[DialogManager] node punya function: ", node["function"])
		_call_function(node["function"])
	else:
		print("[DialogManager] node biasa, tunggu advance()")

func _call_function(fn_name: String) -> void:
	match fn_name:
		"end_dialog":
			end_dialogue()
		_:
			push_warning("DialogManager: fungsi '%s' belum diimplementasi" % fn_name)

func _find_index_by_id(id: String) -> int:
	for i in dialogue_data.size():
		if dialogue_data[i].get("id", "") == id:
			return i
	return -1
