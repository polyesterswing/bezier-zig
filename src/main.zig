const rl = @import("raylib");
const std = @import("std");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    const n = 5;

    const screenWidth = 800;
    const screenHeight = 450;

    var ballPos = std.ArrayList(rl.Vector2).init(allocator);
    defer ballPos.deinit();

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var mousePos: rl.Vector2 = rl.Vector2.init(0, 0);

    // B(t) = (1-t)[(1 - t)P0 + tP1] + t[(1 - t)p1 + tp2]
    while (!rl.windowShouldClose()) {
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            mousePos = rl.getMousePosition();
            if (ballPos.items.len >= n) {
                _ = ballPos.orderedRemove(0);
            }

            try ballPos.append(mousePos);
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        const string = try std.fmt.allocPrintZ(allocator, "{d}", .{ballPos.items.len});
        defer allocator.free(string);

        rl.drawText(string, 190, 200, 20, rl.Color.light_gray);

        // draw all the balls
        for (ballPos.items) |pos| {
            rl.drawCircle(@intFromFloat(pos.x), @intFromFloat(pos.y), 20, rl.Color.red);
        }

        const resolution: u32 = 1000;
        if (ballPos.items.len == n) {
            for (0..resolution) |i| {
                const t: f32 = @as(f32, @floatFromInt(i)) / @as(f32, resolution);

                const pos = bezier(n, 0, n - 1, t, ballPos);

                rl.drawCircle(@intFromFloat(pos.x), @intFromFloat(pos.y), 1, rl.Color.black);
            }
        }
    }
}

pub fn bezier(n: u8, l: u8, r: u8, t: f32, p: anytype) rl.Vector2 {
    if (r == 0) {
        return p.items[r];
    }

    if (l == n - 1) {
        return p.items[l];
    }

    if (l == r) {
        return p.items[r];
    }

    return rl.Vector2.add(rl.Vector2.scale(bezier(n, l, r - 1, t, p), 1 - t), rl.Vector2.scale(bezier(n, l + 1, r, t, p), t));
}
