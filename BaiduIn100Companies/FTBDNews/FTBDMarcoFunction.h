//
//  FTBDMarcoFunction.h
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/8/2.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#ifndef FTBDMarcoFunction_h
#define FTBDMarcoFunction_h


#define ft_weakify_self  @weakify(self)

#define ft_strongify_self \
@strongify(self); \
if (self == nil) { \
return ; \
}


#endif /* FTBDMarcoFunction_h */
