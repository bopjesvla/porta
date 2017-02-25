  create or replace function users_notify() returns trigger as $$
  declare
    data json;
    latest record;
    notification text;
  begin
    latest = case TG_OP
      when 'DELETE' then OLD
      else NEW
    end;
    data = row_to_json(latest);
    notification = json_build_object(
      'table', TG_TABLE_NAME,
      'event', lower(TG_OP),
      'data', data
    );
    perform pg_notify('users', notification::text);
    return null;
  end
  $$ language plpgsql;

  ----- keep this divider

  drop trigger if exists users_notify_trigger on users;

  ----- keep this divider

  create trigger users_notify_trigger
  after insert or update or delete on users
  for each row execute procedure users_notify();
