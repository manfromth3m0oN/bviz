const std = @import("std");
const j = @import("json.zig");
const file = @import("file.zig");
const AAlloc = std.heap.ArenaAllocator;
const process = std.process;
const logger = std.log;
const allocator = std.mem.Allocator;


pub fn main() anyerror!void {
    var arena = AAlloc.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = &arena.allocator;

    var filename = try file.get_fn(alloc);
    var fileContents = try std.fs.cwd().readFileAlloc(alloc, filename, 4096);

    logger.info("{s}", .{fileContents});

    var s = try j.deserialize(alloc, fileContents);
    logger.info("start: {s}, end: {s}, source: {s}", .{s.spans[0].start, s.spans[0].end, s.spans[0].source});
}
