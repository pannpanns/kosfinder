-- Migrasi awal KosFinder (Tahap 3B)
-- Membuat tabel public.kos, index dasar, dan Row Level Security (RLS).

CREATE TABLE IF NOT EXISTS public.kos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
  nama text NOT NULL CHECK (char_length(trim(nama)) > 0),
  area text NOT NULL CHECK (char_length(trim(area)) > 0),
  alamat text NOT NULL CHECK (char_length(trim(alamat)) > 0),
  harga integer NOT NULL CHECK (harga > 0),
  kamar_tersedia integer NOT NULL DEFAULT 1 CHECK (kamar_tersedia >= 0),
  fasilitas text[] NOT NULL CHECK (cardinality(fasilitas) >= 1),
  kontak text NOT NULL CHECK (kontak ~ '^[0-9]{9,14}$'),
  deskripsi text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kos_created_at ON public.kos (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_kos_owner_id ON public.kos (owner_id);

-- Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- 1. Semua orang (termasuk pencari tanpa login) boleh melihat daftar & detail kos
CREATE POLICY "kos_select_public"
  ON public.kos
  FOR SELECT
  USING (true);

-- 2. Hanya pengguna yang sudah login boleh menambah kos atas nama dirinya sendiri
CREATE POLICY "kos_insert_owner"
  ON public.kos
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL AND auth.uid() = owner_id);

-- 3. Hanya pemilik kos tersebut yang boleh mengubah data kos miliknya
CREATE POLICY "kos_update_owner"
  ON public.kos
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- 4. Hanya pemilik kos tersebut yang boleh menghapus kos miliknya
CREATE POLICY "kos_delete_owner"
  ON public.kos
  FOR DELETE
  TO authenticated
  USING (auth.uid() = owner_id);
