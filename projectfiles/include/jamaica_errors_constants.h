#ifndef __JAMAICA_ERRORS_CONSTANTS__
#define __JAMAICA_ERRORS_CONSTANTS__

typedef enum
{
  JAMAICA_ERROR_NONE=0,
  JAMAICA_ERROR_INSUFFICIENT_MEMORY=JAMAICA_ERROR_NONE+2,
  JAMAICA_ERROR_INIT_NATIVE,
  JAMAICA_ERROR_INIT_ROM,
  JAMAICA_ERROR_INIT_ARGUMENTS,
  JAMAICA_ERROR_INVALID_ARGUMENTS,
  JAMAICA_ERROR_INIT_PROFILING,
  JAMAICA_ERROR_INIT_CLASSES,
  JAMAICA_ERROR_INIT_VM_SCHEDULER,
  JAMAICA_ERROR_INIT_VM_EXIT_SIGNAL,
  JAMAICA_ERROR_C_STACK_TOO_SMALL,
  JAMAICA_ERROR_START_VM_SYNC_THREAD,
  JAMAICA_ERROR_START_VM_THREAD,
  JAMAICA_ERROR_TERMINATE_VM_SYNC_THREAD,
  JAMAICA_ERROR_TERMINATE_VM_THREAD,
  JAMAICA_ERROR_STACK_OVERFLOW,
  JAMAICA_ERROR_JAVA_EXCEPTION_PENDING,
  JAMAICA_ERROR_NO_MAIN_CLASS,
  JAMAICA_ERROR_CLASS_NOT_FOUND,
  JAMAICA_ERROR_DEFINE_CLASS_INCOMPATIBLE_CHANGE,
  JAMAICA_ERROR_DEFINE_CLASS_ILLEGAL_ACCESS,
  JAMAICA_ERROR_DEFINE_CLASS_CLASS_FORMAT,
  JAMAICA_ERROR_DEFINE_CLASS_UNSUPPORTED_VERSION,
  JAMAICA_ERROR_DEFINE_CLASS_NO_CLASS_DEF,
  JAMAICA_ERROR_DEFINE_CLASS_SUPERCLASS_IN_ERROR_STATE,
  JAMAICA_ERROR_DEFINE_CLASS_REDEFINE,
  JAMAICA_ERROR_DEFINE_CLASS_WRONG_NAME,
  JAMAICA_ERROR_DEFINE_CLASS_CIRCULARITY,
  JAMAICA_ERROR_DEFINE_CLASS_TOO_MANY_DYNAMIC_TYPES,
  JAMAICA_ERROR_LINK_CLASS_IN_CPOOL_NOT_FOUND,
  JAMAICA_ERROR_RECURSIVE_LINK_FAILURE,
  JAMAICA_ERROR_IO,
  JAMAICA_ERROR_IO_FILE_NOT_FOUND,
  JAMAICA_ERROR_INITIALIZE_CAUSED_EXCEPTION,
  JAMAICA_ERROR_UNCAUGHT_EXCEPTION_HANDLING,
  JAMAICA_ERROR_UNKNOWN_IO_STREAM,
  JAMAICA_ERROR_FIELD_NOT_FOUND,
  JAMAICA_ERROR_METHOD_NOT_FOUND,
  JAMAICA_ERROR_UNSATISFIED_LINK,
  JAMAICA_ERROR_JAVA_STRINGS_NOT_SORTED,
  JAMAICA_ERROR_ILLEGAL_BYTE_CODE,
  JAMAICA_ERROR_UNKNOWN_JAVA_TYPE,
  JAMAICA_ERROR_CREATING_THREAD_OBJECT,
  JAMAICA_ERROR_INIT_COMPILED_CODE,
  JAMAICA_ERROR_JNI,
  JAMAICA_ERROR_ATTACHING_THREAD,
  JAMAICA_ERROR_THREAD_WAKEUP,
  JAMAICA_ERROR_CORRUPTED_JAVA_STACK,
  JAMAICA_ERROR_EMPTY_SCOPE_STACK,
  JAMAICA_ERROR_NC_UNALIGNED_BLOCK,
  JAMAICA_ERROR_NC_BLOCK_OUTSIDE_HEAP,
  JAMAICA_ERROR_NC_NULL_BLOCK,
  JAMAICA_ERROR_NC_BLOCK_INDEX,
  JAMAICA_ERROR_NC_NON_REF,
  JAMAICA_ERROR_NC_REF,
  JAMAICA_ERROR_SYSTEM_FAILURE,
  JAMAICA_ERROR_NO_RUNNING_THREAD,
  JAMAICA_ERROR_VM_EXITING,
  JAMAICA_ERROR_THREAD_TERMINATING,
  JAMAICA_ERROR_JVMTI,
  JAMAICA_ERROR_CORRUPTED_UTF8_DATA,
  JAMAICA_ERROR_UNKNOWN,
  JAMAICA_ERROR_ENUM_END
} jamaica_error;

#endif /* __JAMAICA_ERRORS_CONSTANTS__ */
