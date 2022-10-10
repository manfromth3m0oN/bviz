const std = @import("std");
const AAlloc = std.heap.ArenaAllocator;
const process = std.process;
const logger = std.log;
const json = std.json;
const allocator = std.mem.Allocator;

const fnError = error{
    NoArgs,
    ArgError,
};

const desErr = error {
    DeserializationFail,
};

const JFile = struct {
   spans: []Spans
};

const Spans = struct {
   start: []u8,
   end: []u8,
   source: []u8,
};

fn get_fn(alloc: *allocator) fnError![:0]u8 {
    var args = process.args();
    var argIndex: usize = 0;
    while (args.next(alloc)) |maybeArg| : (argIndex += 1) {
        if (argIndex != 0) {
            var arg = maybeArg catch |err| {
                logger.info("caught error: {s}", .{@errorName(err)});
                return fnError.ArgError;
            };
            logger.info("arg: {s}", .{arg});
            return arg;
        }
    }
    return fnError.NoArgs;
}

fn deserialize(alloc: *allocator, fileContents: []u8) desErr!JFile {
    var stream = json.TokenStream.init(fileContents);
    const jFile = json.parse(JFile, &stream, .{ .allocator = alloc}) catch |err| {
       return desErr.DeserializationFail;
    };
    return jFile;
}

pub fn main() anyerror!void {
    var arena = AAlloc.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = &arena.allocator;

    var filename = try get_fn(alloc);
    var fileContents = try std.fs.cwd().readFileAlloc(alloc, filename, 4096);

    logger.info("{s}", .{fileContents});

    var s = try deserialize(alloc, fileContents);
    logger.info("start: {s}, end: {s}, source: {s}", .{s.spans[0].start, s.spans[0].end, s.spans[0].source});
}
