# Dokumentasi Game RPG 2D

---

## Autoload / Global Scripts

### GameManager
Menyimpan data sesi battle.

| Variable | Tipe | Deskripsi |
|---|---|---|
| `current_enemy` | `Dictionary` | Data musuh yang sedang dilawan |

**Format `current_enemy`:**
```gdscript
{
	"name": String,
	"sprite": Texture2D,
	"hp": int
}
```

---

### InvManager
Mengelola inventory player.

| Variable | Tipe | Deskripsi |
|---|---|---|
| `inv` | `Dictionary` | Semua item yang dimiliki player |

**Format `inv`:**
```gdscript
# Key: item_name (String) dari ItemData.name
# Value:
{
	"resource": ItemData,
	"quantity": int
}
```

**Method:**
```gdscript
add_to_inv(item: ItemData, quantity: int)
# Menambah item ke inventory, atau update quantity jika sudah ada
```

---

### StoreItems
Menyimpan data barang toko.

| Variable | Tipe | Deskripsi |
|---|---|---|
| `storeName` | `String` | Nama toko |
| `testStore` | `Dictionary` | Barang dan harga |

**Format `testStore`:**
```gdscript
# Key: ItemData resource
# Value: harga (int)
{
	load("res://item/tres/apple.tres"): 10,
	load("res://item/tres/stone.tres"): 5,
}
```

---

## Resource

### ItemData (`item_data.gd`)
```gdscript
extends Resource
class_name ItemData

@export var name: String
@export var desc: String
@export var icon: Texture2D
```
Simpan sebagai `.tres` per item di `res://item/tres/`.

---

## Scene & Script

### Map Enemy (`Area2D`)
**Script:** `map_enemy.gd`

```gdscript
@export var enemy_name: String
@export var enemy_sprite: Texture2D
@export var hp: int
```

**Alur:**
1. Player masuk Area2D → deteksi dengan `body is player`
2. Simpan data ke `GameManager.current_enemy`
3. Freeze player dengan `body.set_physics_process(false)`
4. Kamera zoom in via `Tween`
5. Pindah ke `arena.tscn`

**Catatan:** Tiap musuh adalah Inherited Scene dari `map_enemy.tscn`, nilai diisi di Inspector per instance.

---

### Map Item (`Area2D`)
**Script:** `map_item.gd`

```gdscript
@export var item: ItemData
@export var quantity: int = 1
```

**Alur:**
1. Player masuk Area2D
2. Panggil `InvManager.add_to_inv(item, quantity)`
3. `queue_free()` — item hilang dari map

**Catatan:** Sprite item bisa diset dengan `$Sprite2D.texture = item.icon` di `_ready`.

---

### Store (`Area2D`)
**Script:** `store.gd`

**Alur:**
1. Simpan `player_inside = true` saat body entered
2. Simpan `player_inside = false` saat body exited
3. Di `_process`: jika `player_inside` dan tekan `ui_accept` → pindah ke `store_ui.tscn`

---

### Arena (`Node2D`)
**Script:** `arena.gd`

**Setup di `_ready`:**
- Baca `GameManager.current_enemy`
- Set sprite, nama, dan HP bar musuh

**QTE System:**
- Generate sequence panah acak (`ui_up`, `ui_down`, `ui_left`, `ui_right`)
- Sequence ditampilkan sekaligus via `HBoxContainer` berisi `TextureRect`
- Player input satu per satu sesuai urutan
- Input salah → catat `mistakes`, arrow berubah merah, efek shake
- Input benar → arrow fade
- Timer terbatas — habis → `finish_qte()`
- Selesai → hitung damage berdasarkan jumlah `mistakes`

**Variabel penting:**
```gdscript
var sequence: Array = []
var current_index: int = 0
var mistakes: int = 0
var actions: Array = ["ui_up", "ui_down", "ui_left", "ui_right"]
```

---

### Inventory UI (`Control`)
**Script:** `inventory.gd`

**Populate list:**
- Loop `InvManager.inv.keys()`
- Instantiate `inv_row.tscn` per item
- Set nama node row = `item_name` (untuk tracking focus)
- Set focus neighbor atas/bawah antar baris
- `rows[0].find_child("Button").grab_focus()` untuk focus awal

**Focus tracking di `_process`:**
```gdscript
var focusedNode = get_viewport().gui_get_focus_owner()
# naik 1 level: Button → inv_row
var key = focusedNode.get_parent().name
itemLabel.text = key
itemDesc.text = InvManager.inv[key]["resource"].desc
```

**Refresh list setelah update:**
```gdscript
for child in $ScrollContainer/VBoxContainer.get_children():
	child.free()  # bukan queue_free, agar langsung
populate_list()
```

---

### inv_row (`Node2D`)
Scene template untuk satu baris inventory.

**Struktur node:**
```
inv_row
└── Button
	└── HBoxContainer
		├── name (Label)
		└── quant (Label)
```

---

## Struktur Folder (Rekomendasi)
```
res://
├── arena/
│   ├── arena.tscn
│   ├── arena.gd
│   └── arrows/         ← texture panah QTE (svg)
├── item/
│   ├── item_data.gd
│   └── tres/           ← file .tres per item
├── store/
│   └── store_ui.tscn
├── ui/
│   ├── inventory.tscn
│   ├── inventory.gd
│   └── inv_row.tscn
└── world/
	└── world.tscn
```
