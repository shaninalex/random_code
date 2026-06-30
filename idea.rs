use mlua::{Lua, LuaOptions, StdLib};

fn main() -> mlua::Result<()> {
    let lua = Lua::new_with(
        StdLib::MATH | StdLib::STRING | StdLib::TABLE,
        LuaOptions::default(),
    )?;

    let globals = lua.globals();

    // -------------------------
    // scan()
    // -------------------------
    let scan_fn = lua.create_function(|lua, ()| {
        let enemies = lua.create_table()?;

        let enemy1 = lua.create_table()?;
        enemy1.set("x", 12)?;
        enemy1.set("y", 8)?;

        enemies.set(1, enemy1)?;

        Ok(enemies)
    })?;

    globals.set("scan", scan_fn)?;

    // -------------------------
    // fire(x, y)
    // -------------------------
    let fire_fn = lua.create_function(|_, (x, y): (i32, i32)| {
        println!("FIRE at ({}, {})", x, y);
        Ok(())
    })?;

    globals.set("fire", fire_fn)?;

    // -------------------------
    // move(x, y)
    // -------------------------
    let move_fn = lua.create_function(|_, (x, y): (i32, i32)| {
        println!("MOVE to ({}, {})", x, y);
        Ok(())
    })?;

    globals.set("move", move_fn)?;

    // -------------------------
    // Lua script
    // -------------------------
    lua.load(r#"
        local enemies = scan()

        if #enemies > 0 then
            fire(enemies[1].x, enemies[1].y)
        else
            move(10, 20)
        end
    "#).exec()?;

    Ok(())
}
