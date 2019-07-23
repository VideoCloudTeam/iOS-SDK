//
//  ViaNetworkRequestV3API.m
//  linphone
//
//  Created by mac on 2019/5/23.
//

#import "ViaNetworkRequestV3API.h"
#import "NetBridge.h"
#import "NSMutableDictionary+WQHTTP.h"
@implementation ViaNetworkRequestV3API
//MARK: 专属云API
+ (NSString *)sessionId {
    NSDictionary *userInfor = [[NSUserDefaults standardUserDefaults]objectForKey:@"curryUserToken"];
    NSString *sessionId = userInfor[@"sessionId"];
 return sessionId;
}

/**
 通讯录搜索部门
 
 @param cmdid 参数值： "search_department_ids"， 表明此次请求的目的
 @param filter_type filter_type 表示筛选部门的过滤字段名， 即过滤条件名称。 其内可取的值为： "department_id"、 "department_name"、 "senior_id"、 "department_desc"、 "creator_usr_id"、 "create_dtm"， 分别表示 部门id、 部门名称、 父级部门id、 部门描述、 创建者id、 创建时间。
 
 @param filterValue department_id
 int 型， 大于 0 的整数
 department_name
 string 型， 支持对此字段模糊查询
 senior_id
 int 型， 大于等于 -1 的整数
 department_desc
 string 型
 creator_usr_id
 int 型， 大于 0 的整数
 */
+ (NSURLSessionDataTask *)superDepartmentId:(NSArray *)filter_type filterValue: (NSArray *)filterValue success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
    NSString *urlString = [NSString stringWithFormat:@"/rest/v1/app1/manager/sessions/%@%@",[ViaNetworkRequestV3API sessionId], @"/departments/department_ids/search/"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"search_department_ids" forField:@"cmdid"];
    [paramDic setObject:filter_type forField:@"filter_type"];
    [paramDic setObject:filterValue forField:@"filter_value"];
    return [NetBridge postV3WithApi:urlString params:paramDic success:success failure:failure];
}


/**
 获取部门下资源信息
 @param department_id 想要获取资源信息的部门id
 @param option "usr"、 "room" 、"endpoint"、 "manager"、 "usr_manager"、 "account"、 "cascade"、 "mr_template"， 分别表示想要获取 用户、 会诊室、 终端、 管理员、 用户和管理员、 所有账户（包括用户、终端、管理员）、 级联点、 会诊模板 的信息
 */
+ (NSURLSessionDataTask *)childrenDepartment: (NSNumber *)department_id option: (NSString *)option success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
        NSString *urlString = [NSString stringWithFormat:@"/rest/v1/app1/manager/sessions/%@%@",[ViaNetworkRequestV3API sessionId], @"/departments/children_ids/"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"get_department" forField:@"cmdid"];
    [paramDic setObject:department_id forField:@"department_id"];
    [paramDic setObject:option forField:@"option"];
    return [NetBridge postV3WithApi:urlString params:paramDic success:success failure:failure];
}


/**
 部门详情

 @param department_ids 部门ID
 @param last_modify_dtms 每个部门对应的上次修改时间， int 型的UTC时间戳， 单位： 秒。 详【注①】 */
+ (NSURLSessionDataTask *)departmentDetail: (NSArray *)department_ids last_modify_dtms:(NSArray *)last_modify_dtms success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
    NSString *urlString = [NSString stringWithFormat:@"/rest/v1/app1/manager/sessions/%@%@",[ViaNetworkRequestV3API sessionId], @"/departments/department_ids/"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"subscribe_departmen" forField:@"cmdid"];
    [paramDic setObject:department_ids forField:@"department_ids"];
    [paramDic setObject:last_modify_dtms forField:@"last_modify_dtms"];
    return [NetBridge postV3WithApi:urlString params:paramDic success:success failure:failure];
}


/**
 筛选用户、终端、级联点

 @param filter_type filter_type 表示筛选账户的过滤字段名， 即过滤条件名称。 其内可取的值为： "login_id"、 "usr_id"、 "cuid"、 "usr_mark"、 "phone_no"、 "nick_name"、 "priority"、 "email"、 "activate"、 "usr_type"、 "creator_usr_id"、 "create_dtm"、 "ptotocol_type"、 "call_addr"、 "max_room"、 "verify"、 "is_endpoint"、 "gender"、 "duty"、 "fixed_phone"、 "is_used"， 分别表示 账号、 账户id、 完整的用户号、 用户号（完整的用户号去掉租户局号剩下的部分）、 电话号码、 昵称、 优先级、 邮箱地址、 账户状态、 账户类型、 创建者id、 创建时间、 协议类型、 被呼地址、 最大私有会诊室数、 验证状态、 是否为端、 性别、 职位、 座机号码、本次筛选的目的
 @param filter_value
 login_id
 string 型
 usr_id
 int 型， 大于 0 的整数
 cuid
 string 型， 只能是 8 位纯数字组成的字符串
 usr_mark
 string 型， 用户号， 是 cuid 中去掉租户局号剩下的部分， 纯数字字符串
 phone_no
 string 型
 nick_name
 string 型
 priority
 int 型， 优先级， 从 0 到 999， 数字越小， 优先级越高
 email
 string 型
 activate
 list 型， 内部包含多个由 0 和 1 组成的长度为 2 的字符串， 取值只能为 "00" 或 "01" 或 "10" 或 "11"， 支持多个字符串同时过滤， 左边一位表示是否启用， 右边一位表示是否激活。 如： "01" 表示禁用激活状态， 而 "10" 表示启用未激活状态
 usr_type
 int 型， 2 表示用户， 3 表示级联点（须配合is_endpoint字段一起使用）
 creator_usr_id
 int 型， 大于 0 的整数
 create_dtm
 list 型， 详见下面说明
 ptotocol_type
 int 型， 1 H323协议， 2 SIP协议， 3 多流协议
 call_addr
 string 型
 max_room
 int 型， 大于 0 的整数
 verify
 string 型， 由 0 和 1 组成的长度为 2 的字符串， 左边一位表示手机号码是否验证， 右边一位表示邮箱是否验证， 0 表示否， 1 表示是
 is_endpoint
 int 型， 0 表示不是端， 1 表示端， 2 表示级联点（须配合usr_type一起使用）
 gender
 int 型， 0 表示女性， 1 表示男性
 duty
 string 型， 如 "董事长" 等
 fixed_phone
 string 型
 is_used
 int 型， 此次筛选是为了使用资源还是为了管理（或查看）资源， 如果是为了使用， 则此值为必传， 传 int 型的 1， 如果是为了管理（或查看）则不需要传

 */
+ (NSURLSessionDataTask *)accordingToInfoSearchUserIds: (NSArray *)filter_type filter_value: (NSArray *)filter_value success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
            NSString *urlString = [NSString stringWithFormat:@"/rest/v1/app1/manager/sessions/%@%@",[ViaNetworkRequestV3API sessionId], @"/usrs/usr_id/search/"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"search_usr" forField:@"cmdid"];
    [paramDic setObject:filter_type forField:@"filter_type"];
    [paramDic setObject:filter_value forField:@"filter_value"];
    return [NetBridge postV3WithApi:urlString params:paramDic success:success failure:failure];
}


/**
 订阅用户、终端、级联点 根据用户ID搜索用户

 @param usr_ids 用户ID 需要订阅详细信息的账户id组成的列表， 元素为 int 型， 单次订阅数量上限为 100个， 超过 100 个服务器将不予理会并返回http状态码
 @param last_modify_dtm 上次更改的UTC时间戳， 元素为 int 型， 单位： 秒。 在位置上须与 usr_ids 中的id一一对应， 首次调用此接口， id对应的上次修改时间传 0
 */
+ (NSURLSessionDataTask *)accordingToUserIdSearchUserInfo: (NSArray *)usr_ids last_modify_dtm: (NSArray *)last_modify_dtm success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
                NSString *urlString = [NSString stringWithFormat:@"/rest/v1/app1/manager/sessions/%@%@",[ViaNetworkRequestV3API sessionId], @"/usrs/usr_ids/"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"subscribe_usr" forField:@"cmdid"];
    [paramDic setObject:usr_ids forField:@"usr_ids"];
    [paramDic setObject:last_modify_dtm forField:@"last_modify_dtms"];
    return [NetBridge postV3WithApi:urlString params:paramDic success:success failure:failure];
}
/**
 专属云 发送验证码
 @param phoneNumber 手机号
 */
+ (NSURLSessionDataTask *)forgetPasswordSendMessage: (NSString *)phoneNumber success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *url = @"/rest/v1/app1/user/phone_for_reset_pwd/";
    [paramDic setObject: @"phone_for_reset_pwd" forField:@"cmdid"];
    [paramDic setObject: phoneNumber forField:@"phone_no"];
   return [NetBridge postV3WithApi:url params:paramDic success:success failure:failure];
}


/**
 忘记密码重置密码

 @param phoneNumber 手机号
 @param code 验证码
 @param password 密码
 */
+ (NSURLSessionDataTask *)forgetPasswordSetPassword: (NSString *)phoneNumber code: (NSString *)code password: (NSString *)password success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
    NSString *url = @"/rest/v1/app1/user/reset_pwd_byphone/";
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject: @"reset_pwd_byphone_rsp" forField:@"cmdid"];
    [paramDic setObject: phoneNumber forField:@"phone_no"];
    [paramDic setObject: code forField:@"code"];
    [paramDic setObject: password forField:@"password"];
    return [NetBridge postV3WithApi:
            url params:paramDic success:success failure:failure];
}

+ (NSURLSessionDataTask *)getChangesnApiServer:(NSString *)server andSesstion:(NSString *)sessionId success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure{
    NSString *urlString = [NSString stringWithFormat:@"/rest/v1/app1/manager/sessions/%@%@", sessionId, @"/data/"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic setObject: @"get_changes" forField:@"cmdid"];
    [paramDic setObject: [NSNumber numberWithInt:10] forField:@"block_secs"];
    return [NetBridge postV3WithApi:
            urlString params:paramDic success:success failure:failure];
}

+ (NSURLSessionDataTask *)loginApiServer:(NSString *)server withUserName:(NSString*)address password:(NSString*)password success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
    NSString *urlString = [NSString stringWithFormat:@"/api/v3/app/user/login/verify_user.shtml"];

    NSMutableDictionary *parameter = [NSMutableDictionary new];
    [parameter setObject:address forField:@"account"];
    [parameter setObject:password forField:@"pwd"] ;
    [parameter setObject:@"webrtcc4" forKey:@"plat_type"];
    return [NetBridge postV3WithApi:urlString params:parameter success:success failure:failure] ;
}







@end
