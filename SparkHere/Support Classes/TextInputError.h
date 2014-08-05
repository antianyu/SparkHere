//
//  TextInputError.h
//  SparkHere
//
//  Created by Tianyu An on 14-7-24.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#ifndef IP_TextInputError_h
#define IP_TextInputError_h

typedef enum
{
    TextInputErrorUserName,
    TextInputErrorPassword,
    TextInputErrorConfirmPassword,
    TextInputErrorOriginalPassword,
    TextInputErrorNewPassword,
    TextInputErrorNickname,
    TextInputErrorChannelName,
    TextInputErrorDescription,
    TextInputErrorMessageContent,
    TextInputErrorNone,
    
} TextInputError;

#endif