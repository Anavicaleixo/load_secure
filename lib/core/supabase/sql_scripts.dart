/// SQL para criação das tabelas no Supabase — LoadSecure.
/// Execute estes scripts no SQL Editor do painel do Supabase:
/// https://supabase.com/dashboard/project/xbtlhqfbqvjgyqdhnsst/sql
abstract class SqlScripts {
  /// ─── 1. Tabela PROFILES ──────────────────────────────────────────────────
  /// Extensão da tabela auth.users com dados do perfil do usuário.
  static const String createProfiles = '''
-- 1. PROFILES (estende auth.users)
create table public.profiles (
  id          uuid        references auth.users(id) on delete cascade primary key,
  name        text        not null,
  company     text,
  phone       text,
  role        text        not null default \'operator\',
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- RLS
alter table public.profiles enable row level security;

create policy "Usuário vê seu próprio perfil"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Usuário atualiza seu próprio perfil"
  on public.profiles for update
  using (auth.uid() = id);

-- Trigger: cria perfil automaticamente após cadastro
create or replace function public.handle_new_user()
returns trigger as \$\$
begin
  insert into public.profiles (id, name, company, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> \'name\', split_part(new.email, \'@\', 1)),
    new.raw_user_meta_data ->> \'company\',
    new.raw_user_meta_data ->> \'phone\'
  );
  return new;
end;
\$\$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
''';

  /// ─── 2. Tabela SECTORS ───────────────────────────────────────────────────
  static const String createSectors = '''
-- 2. SECTORS (setores industriais)
create table public.sectors (
  id          uuid        default gen_random_uuid() primary key,
  name        text        not null,
  description text,
  created_at  timestamptz not null default now()
);

alter table public.sectors enable row level security;

create policy "Usuários autenticados visualizam setores"
  on public.sectors for select
  to authenticated
  using (true);

create policy "Usuários autenticados gerenciam setores"
  on public.sectors for all
  to authenticated
  using (true);
''';

  /// ─── 3. Tabela MACHINES ──────────────────────────────────────────────────
  static const String createMachines = '''
-- 3. MACHINES (máquinas/equipamentos)
create table public.machines (
  id               uuid        default gen_random_uuid() primary key,
  name             text        not null,
  type             text        not null,
  sector_id        uuid        references public.sectors(id) on delete set null,
  status           text        not null default \'offline\'
                               check (status in (\'online\', \'offline\', \'maintenance\', \'alert\')),
  efficiency       float       not null default 0
                               check (efficiency >= 0 and efficiency <= 100),
  temperature      float       not null default 0,
  up_time_minutes  int         not null default 0,
  last_maintenance timestamptz not null default now(),
  image_url        text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

alter table public.machines enable row level security;

create policy "Usuários autenticados visualizam máquinas"
  on public.machines for select
  to authenticated
  using (true);

create policy "Usuários autenticados gerenciam máquinas"
  on public.machines for all
  to authenticated
  using (true);
''';

  /// ─── 4. Tabela ALERTS ────────────────────────────────────────────────────
  static const String createAlerts = '''
-- 4. ALERTS (alertas das máquinas)
create table public.alerts (
  id          uuid        default gen_random_uuid() primary key,
  machine_id  uuid        references public.machines(id) on delete cascade,
  type        text        not null,
  message     text        not null,
  severity    text        not null default \'info\'
              check (severity in (\'info\', \'warning\', \'critical\')),
  resolved    boolean     not null default false,
  resolved_at timestamptz,
  created_at  timestamptz not null default now()
);

alter table public.alerts enable row level security;

create policy "Usuários autenticados visualizam alertas"
  on public.alerts for select
  to authenticated
  using (true);

create policy "Usuários autenticados gerenciam alertas"
  on public.alerts for all
  to authenticated
  using (true);
''';

  /// Todos os scripts em ordem de execução.
  static const List<Map<String, String>> all = [
    {'title': '1. Profiles', 'sql': createProfiles},
    {'title': '2. Sectors',  'sql': createSectors},
    {'title': '3. Machines', 'sql': createMachines},
    {'title': '4. Alerts',   'sql': createAlerts},
  ];
}
