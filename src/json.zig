const allocator = @import("std").mem.Allocator;
const json = @import("std").json;

const JFile = struct {
   spans: []Spans
};

const Spans = struct {
   start: []u8,
   end: []u8,
   source: []u8,
};


pub const desErr = error {
    DeserializationFail,
};

pub fn deserialize(alloc: *allocator, fileContents: []u8) desErr!JFile {
    var stream = json.TokenStream.init(fileContents);
    const jFile = json.parse(JFile, &stream, .{ .allocator = alloc}) catch |err| {
       return desErr.DeserializationFail;
    };
    return jFile;
}

