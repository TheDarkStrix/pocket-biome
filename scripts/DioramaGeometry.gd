extends RefCounted
# Authored low-poly forms are merged by material, rather than one node per detail.
var batches := {}
static var primitives := {}
func stream(category: String) -> SurfaceTool:
 if not batches.has(category):
  var s := SurfaceTool.new(); s.begin(Mesh.PRIMITIVE_TRIANGLES); batches[category] = s
 return batches[category]
func append_mesh(mesh: Mesh, transform: Transform3D, color: Color, category: String = "solid") -> void:
 var a := mesh.surface_get_arrays(0)
 var vertices: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
 var normals: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
 var uvs: PackedVector2Array = a[Mesh.ARRAY_TEX_UV]
 var indices: PackedInt32Array = a[Mesh.ARRAY_INDEX]
 var s := stream(category)
 var normal_basis := transform.basis.inverse().transposed()
 for i in range(indices.size() if not indices.is_empty() else vertices.size()):
  var at: int = indices[i] if not indices.is_empty() else i
  s.set_color(color); s.set_normal((normal_basis*normals[at]).normalized()); s.set_uv(uvs[at] if not uvs.is_empty() else Vector2.ZERO)
  s.add_vertex(transform*vertices[at])
func box(at: Vector3, size: Vector3, color: Color, category: String = "solid", rotation: Vector3 = Vector3.ZERO) -> void:
 if not primitives.has("box"):
  var mesh := BoxMesh.new(); mesh.size = Vector3.ONE; primitives.box = mesh
 append_mesh(primitives.box,Transform3D(Basis.from_euler(rotation).scaled(size),at),color,category)
func beam(a: Vector3, b: Vector3, width: float, color: Color, category: String = "solid") -> void:
 var axis := (b-a).normalized()
 var helper := Vector3.RIGHT if absf(axis.dot(Vector3.UP)) > 0.98 else Vector3.UP
 var x := helper.cross(axis).normalized(); var z := x.cross(axis).normalized()
 if not primitives.has("box"):
  var mesh := BoxMesh.new(); mesh.size = Vector3.ONE; primitives.box = mesh
 append_mesh(primitives.box,Transform3D(Basis(x*width,axis*a.distance_to(b),z*width),(a+b)/2),color,category)
func cylinder(at: Vector3, radius: float, height: float, color: Color, top_ratio: float = 1.0, category: String = "solid") -> void:
 var mesh := CylinderMesh.new(); mesh.radial_segments = 10; mesh.rings = 1
 mesh.bottom_radius = radius; mesh.top_radius = radius*top_ratio; mesh.height = height
 append_mesh(mesh,Transform3D(Basis.IDENTITY,at),color,category)
func lump(at: Vector3, size: Vector3, color: Color, seed: int, category: String = "solid") -> void:
 # Radially sculpted foliage/stone with smooth normals; no repeated perfect balls.
 var mesh := SphereMesh.new(); mesh.radial_segments = 10; mesh.rings = 5; mesh.radius = 1; mesh.height = 2
 var a := mesh.surface_get_arrays(0); var p: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
 for i in range(p.size()):
  var v := p[i]; var swell := 0.92+0.07*sin(v.x*5+seed)+0.055*cos(v.z*7-seed*0.7)+0.035*sin(v.y*11+seed)
  p[i] = v*swell
 a[Mesh.ARRAY_VERTEX] = p
 var shaped := ArrayMesh.new(); shaped.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,a)
 append_mesh(shaped,Transform3D(Basis.IDENTITY.scaled(size),at),color,category)
func triangle(a: Vector3,b: Vector3,c: Vector3,color: Color,category: String = "solid", ua: Vector2 = Vector2.ZERO,ub: Vector2 = Vector2.RIGHT,uc: Vector2 = Vector2.ONE) -> void:
 var normal := (b-a).cross(c-a).normalized(); var s := stream(category)
 for item in [[a,ua],[c,uc],[b,ub]]:
  s.set_normal(normal);s.set_color(color);s.set_uv(item[1]);s.add_vertex(item[0])
func finish(parent: Node3D, materials: Dictionary) -> void:
 for category in batches:
  var node := MeshInstance3D.new(); node.mesh = batches[category].commit(); node.material_override = materials[category]
  node.name = category; parent.add_child(node)
 batches.clear()
