#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>
#import <os/log.h>
#import <string.h>
#import <stdlib.h>
#import <stdarg.h>

static os_log_t rr_log_handle;

static void rr_log_message(os_log_type_t type, const char *format, ...) {
    char message[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(message, sizeof(message), format, args);
    va_end(args);

    if (!rr_log_handle) {
        rr_log_handle = os_log_create("com.shalamand3r.relayrace", "runtime");
    }
    os_log_with_type(rr_log_handle, type, "%{public}s", message);
}

static BOOL rr_is_networkserviceproxy(void) {
    const char *processName = getprogname();
    return processName && strcmp(processName, "networkserviceproxy") == 0;
}

static BOOL rr_method_returns_bool(Method method) {
    const char *types = method_getTypeEncoding(method);
    if (!types || !types[0]) return NO;
    return types[0] == 'B' || types[0] == 'c' || types[0] == 'C';
}

static void rr_verify_signature_bypass(id self, SEL _cmd, id signature, id configuration, id host, BOOL validateCert, id completionHandler) {
    (void)self;
    (void)_cmd;
    (void)signature;
    (void)configuration;
    (void)host;
    (void)validateCert;

    if (completionHandler) {
        void (^completion)(BOOL, id) = completionHandler;
        completion(YES, nil);
    }
}

static BOOL rr_validate_configuration_bypass(id self, SEL _cmd, id configuration) {
    (void)self;
    (void)_cmd;
    (void)configuration;

    return YES;
}

static BOOL rr_patch_method(Method method, IMP replacement) {
    if (!method) return NO;
    if (method_getImplementation(method) == replacement) return NO;
    method_setImplementation(method, replacement);
    return YES;
}

static BOOL rr_patch_method_list(Class cls, BOOL meta, SEL sel, IMP replacement, BOOL requireBoolReturn) {
    Class methodClass = meta ? object_getClass(cls) : cls;
    if (!methodClass) return NO;

    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(methodClass, &methodCount);
    if (!methods) return NO;

    BOOL patched = NO;
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        if (method_getName(method) != sel) continue;
        if (requireBoolReturn && !rr_method_returns_bool(method)) continue;

        patched |= rr_patch_method(method, replacement);
    }

    free(methods);
    return patched;
}

static unsigned int rr_scan_and_patch_direct_bypass(BOOL initialScan) {
    if (!rr_is_networkserviceproxy()) {
        rr_log_message(OS_LOG_TYPE_ERROR, "Skipped bypass: unexpected process %s", getprogname() ?: "unknown");
        return 0;
    }

    SEL verifySel = @selector(verifyConfigurationSignature:configuration:host:validateCert:completionHandler:);
    SEL validateSel = @selector(validatePrivacyProxyConfiguration:);

    const char *classNames[] = {
        "NSPConfigurationSignatureInfo",
        "NSPPrivacyProxySignedConfiguration",
        "NSPPrivacyProxyConfiguration",
        "NSPConfiguration",
        "NSPConfigurationManager",
        "NSPServer",
        NULL
    };

    unsigned int classesFound = 0;
    unsigned int methodsPatched = 0;

    for (const char **name = classNames; *name; name++) {
        Class cls = objc_lookUpClass(*name);
        if (!cls) continue;
        classesFound++;

        methodsPatched += rr_patch_method_list(cls, YES, verifySel, (IMP)rr_verify_signature_bypass, NO);
        methodsPatched += rr_patch_method_list(cls, NO, verifySel, (IMP)rr_verify_signature_bypass, NO);
        methodsPatched += rr_patch_method_list(cls, YES, validateSel, (IMP)rr_validate_configuration_bypass, YES);
        methodsPatched += rr_patch_method_list(cls, NO, validateSel, (IMP)rr_validate_configuration_bypass, YES);
    }

    if (initialScan || methodsPatched > 0) {
        rr_log_message(methodsPatched > 0 ? OS_LOG_TYPE_DEFAULT : OS_LOG_TYPE_ERROR,
                       "Bypass scan complete: %u classes, %u methods patched",
                       classesFound, methodsPatched);
    }
    return methodsPatched;
}

%hook NSPConfiguration

- (BOOL)ignoreSignature {
    return YES;
}

- (BOOL)ignoreInvalidCerts {
    return YES;
}

%end

%ctor {
    if (rr_is_networkserviceproxy()) {
        rr_log_message(OS_LOG_TYPE_DEFAULT, "Loaded into networkserviceproxy");
        rr_scan_and_patch_direct_bypass(YES);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            rr_scan_and_patch_direct_bypass(NO);
        });
    } else {
        rr_log_message(OS_LOG_TYPE_ERROR, "Loaded into unexpected process %s; no hooks applied",
                       getprogname() ?: "unknown");
    }
}
