// Run: %dxc -T lib_6_3 -fspv-target-env=vulkan1.2
// CHECK:  OpCapability RayTracingKHR
// CHECK:  OpCapability RayQueryKHR
// CHECK:  OpExtension "SPV_KHR_ray_tracing"
// CHECK:  OpExtension "SPV_KHR_ray_query"

RaytracingAccelerationStructure AccelerationStructure : register(t0);
RayDesc MakeRayDesc()
{
    RayDesc desc;
    desc.Origin = float3(0,0,0);
    desc.Direction = float3(1,0,0);
    desc.TMin = 0.0f;
    desc.TMax = 9999.0;
    return desc;
}
void doInitialize(RayQuery<RAY_FLAG_FORCE_OPAQUE> query, RayDesc ray)
{
    query.TraceRayInline(AccelerationStructure,RAY_FLAG_FORCE_NON_OPAQUE,0xFF,ray);
}

struct Payload
{
  float4 color;
};

[shader("miss")]
void main(inout Payload MyPayload) {
  Payload myPayload = { float4(0.0f,0.0f,0.0f,0.0f) };
  RayQuery<RAY_FLAG_FORCE_OPAQUE> q;
  RayDesc ray = MakeRayDesc();
// CHECK:  [[accel:%\d+]] = OpLoad %accelerationStructureNV %AccelerationStructure
// CHECK:  OpRayQueryInitializeKHR [[rayquery]] [[accel]] %uint_1 %uint_255 {{%\d+}} %float_0 {{%\d+}} %float_9999
  q.TraceRayInline(AccelerationStructure,RAY_FLAG_FORCE_OPAQUE, 0xFF, ray);
// CHECK: OpRayQueryInitializeKHR [[rayquery]] [[accel]] %uint_3 %uint_255 {{%\d+}} %float_0 {{%\d+}} %float_9999
  doInitialize(q, ray);
}
