#lang racket
(require ffi/unsafe)
(require ffi/cvector)
(require ffi/vector)
(require opencl/c)
(require opencl/racket)

(define count 1024000)

(define kernel_source
#"
__kernel void square(__global float* input, __global float* output, const unsigned int count){
  int i = get_global_id(0);
  if(i < count)
    output[i] = input[i] * input[i];
}
")

(define data
  (apply f32vector 
         (for/list ([x (in-range 0 count)])
           (random))))
(define results (make-f32vector count))

(define devices (platform-devices #f 'CL_DEVICE_TYPE_GPU))
(define device-id (cvector-ref devices 0))
(define vendor-name (device-info device-id 'CL_DEVICE_VENDOR))
(define device-name (device-info device-id 'CL_DEVICE_NAME))
(printf "###Connecting to ~a ~a~n###" vendor-name device-name)

(define platform (cvector-ref (clGetPlatformIDs:vector) 0))
(for ([p (in-list '(CL_PLATFORM_PROFILE CL_PLATFORM_VERSION CL_PLATFORM_NAME CL_PLATFORM_VENDOR CL_PLATFORM_EXTENSIONS))])
  (printf "~a ~a~n" p (clGetPlatformInfo:generic platform p)))

(define device (cvector-ref (clGetDeviceIDs:vector platform 'CL_DEVICE_TYPE_GPU) 0))

(define context (clCreateContext #f (vector device)))

(define commands (clCreateCommandQueue context device '()))

(define program (clCreateProgramWithSource context (vector kernel_source)))

(clBuildProgram program (vector device) #"")

(define kernel (clCreateKernel program #"square"))

(define input  (clCreateBuffer context 'CL_MEM_READ_ONLY  (* count (ctype-sizeof _float)) #f))
(define output (clCreateBuffer context 'CL_MEM_WRITE_ONLY (* count (ctype-sizeof _float)) #f))

(clEnqueueWriteBuffer commands input 'CL_TRUE 0 (* count (ctype-sizeof _float)) (f32vector->cpointer data) (vector))
(clSetKernelArg:_cl_mem kernel 0 input)
(clSetKernelArg:_cl_mem kernel 1 output)
(clSetKernelArg:_cl_uint kernel 2 count)


(printf "length: ~a~n" (clGetKernelWorkGroupInfo:length  kernel device 'CL_KERNEL_WORK_GROUP_SIZE))
(printf "length: ~a~n" (clGetKernelWorkGroupInfo:length	kernel device 'CL_KERNEL_COMPILE_WORK_GROUP_SIZE))
(define local (clGetKernelWorkGroupInfo:_size_t kernel device 'CL_KERNEL_WORK_GROUP_SIZE))
(printf "kernel work group size: ~a~n" local)

(clEnqueueNDRangeKernel commands kernel 1 (vector count) (vector local) (vector))

(clFinish commands)

(clEnqueueReadBuffer commands output 'CL_TRUE 0 (* count (ctype-sizeof _float)) (f32vector->cpointer results) (vector))

(clReleaseMemObject input)
(clReleaseMemObject output)
(clReleaseProgram program)
(clReleaseKernel kernel)
(clReleaseCommandQueue commands)
(clReleaseContext context)

(/
 (for/sum ([cl (in-list (f32vector->list results))]
           [orig (in-list (f32vector->list data))])
   (abs (- cl (* orig orig))))
 count)
