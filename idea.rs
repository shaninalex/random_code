use mlua::{Lua, LuaOptions, StdLib};

fn main() {
    let lua = Lua::new_with(
        StdLib::MATH | StdLib::STRING | StdLib::TABLE,
        LuaOptions::default(),
    ).unwrap();

    let globals = lua.globals();

    let scan_fn = lua.create_function(|lua, ()| {
        let enemies = lua.create_table().unwrap();

        let enemy1 = lua.create_table().unwrap();
        enemy1.set("x", 12).unwrap();
        enemy1.set("y", 8).unwrap();

        enemies.set(1, enemy1).unwrap();

        Ok(enemies)
    }).unwrap();

    globals.set("scan", scan_fn).unwrap();

    let fire_fn = lua.create_function(|_, (x, y): (i32, i32)| {
        println!("FIRE at ({}, {})", x, y);
        Ok(())
    }).unwrap();

    globals.set("fire", fire_fn).unwrap();

    let move_fn = lua.create_function(|_, (x, y): (i32, i32)| {
        println!("MOVE to ({}, {})", x, y);
        Ok(())
    }).unwrap();

    globals.set("move", move_fn).unwrap();

    lua.load(r#"
        local enemies = scan()

        if #enemies > 0 then
            fire(enemies[1].x, enemies[1].y)
        else
            move(10, 20)
        end
    "#).exec().unwrap();
}
