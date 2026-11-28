-- Memberi izin akses level tabel agar role anon dapat membaca kos
-- dan role authenticated dapat mengelola kos miliknya sesuai policy RLS.
GRANT SELECT ON TABLE public.kos TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.kos TO authenticated;
