extends RefCounted
# Small dependency-free GIF89a export. Frequent clear codes keep LZW at 9 bits.
static func word(out: PackedByteArray, value: int) -> void:
 out.append(value & 255); out.append((value >> 8) & 255)
static func encode(frames: Array, delay: int = 120) -> PackedByteArray:
 if frames.is_empty() or frames.size() > 4: return PackedByteArray()
 for frame in frames:
  if not frame is Image or frame.is_empty(): return PackedByteArray()
 var width: int = mini(180,frames[0].get_width())
 var height: int = clampi(roundi(frames[0].get_height()*float(width)/frames[0].get_width()),1,320)
 var out := "GIF89a".to_ascii_buffer()
 word(out,width); word(out,height); out.append_array(PackedByteArray([247,0,0]))
 for index in range(256): out.append_array(PackedByteArray([roundi(((index >> 5) & 7)*255.0/7),roundi(((index >> 2) & 7)*255.0/7),roundi((index & 3)*255.0/3)]))
 out.append_array(PackedByteArray([33,255,11])); out.append_array("NETSCAPE2.0".to_ascii_buffer()); out.append_array(PackedByteArray([3,1,0,0,0]))
 for original in frames:
  var image: Image = original.duplicate(); image.resize(width,height,Image.INTERPOLATE_LANCZOS); image.convert(Image.FORMAT_RGB8)
  var data := image.get_data(); var codes := PackedInt32Array()
  for pixel in range(width*height):
   if pixel%200 == 0: codes.append(256)
   var at := pixel*3
   codes.append(((int(data[at]) >> 5) << 5) | ((int(data[at+1]) >> 5) << 2) | (int(data[at+2]) >> 6))
  codes.append(257)
  var encoded := PackedByteArray(); var bits := 0; var buffer := 0
  for code in codes:
   buffer |= int(code) << bits; bits += 9
   while bits >= 8: encoded.append(buffer & 255); buffer >>= 8; bits -= 8
  if bits > 0: encoded.append(buffer & 255)
  out.append_array(PackedByteArray([33,249,4,4])); word(out,clampi(delay,20,1000)); out.append_array(PackedByteArray([0,0,44]))
  word(out,0); word(out,0); word(out,width); word(out,height); out.append_array(PackedByteArray([0,8]))
  for start in range(0,encoded.size(),255):
   var block: PackedByteArray = encoded.slice(start,mini(start+255,encoded.size()))
   out.append(block.size()); out.append_array(block)
  out.append(0)
 out.append(59)
 return out
static func save(path: String, frames: Array) -> bool:
 var data := encode(frames)
 if data.is_empty(): return false
 var file = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file == null: return false
 file.store_buffer(data); file.flush(); var ok: bool = file.get_error() == OK; file.close()
 return ok and DirAccess.rename_absolute(path+".tmp",path) == OK
