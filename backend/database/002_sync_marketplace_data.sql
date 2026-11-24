INSERT IGNORE INTO kategori (id_kategori, nama_kategori) VALUES
    (1, 'FamiCafé'),
    (2, 'Siap Saji'),
    (3, 'Oden & Snack'),
    (4, 'Minuman');

INSERT IGNORE INTO produk
    (id_produk, id_kategori, nama_produk, harga, stok, foto)
VALUES
    (1, 1, 'Kopi Susu Keluarga (KSK)', 18000, 50,
     'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=700'),
    (2, 2, 'Onigiri Tuna Mayo', 14000, 30,
     'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=700'),
    (3, 2, 'Crispy Chicken Nugget Bowl', 22000, 25,
     'https://images.unsplash.com/photo-1562967914-608f82629710?w=700'),
    (4, 1, 'Iced Matcha Latte', 20000, 40,
     'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=700'),
    (5, 3, 'Oden Kuah Tomyum', 19000, 20,
     'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700'),
    (6, 4, 'Air Mineral 600ml', 5000, 100,
     'https://images.unsplash.com/photo-1560023907-5f339617ea30?w=700');
