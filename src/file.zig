const allocator = @import("std").mem.Allocator;
const process = @import("std").process;

pub const fnError = error{
    NoArgs,
    ArgError,
};

pub fn get_fn(alloc: allocator) fnError![:0]u8 {
    var args = process.args();
    var argIndex: usize = 0;
    while (args.next(alloc)) |maybeArg| : (argIndex += 1) {
        if (argIndex != 0) {
            var arg = maybeArg catch {
                return fnError.ArgError;
            };
            return arg;
        }
    }
    return fnError.NoArgs;
}

