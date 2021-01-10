---
title: Github上mall开源项目的学习
date: 2020-12-02 19:56:55
permalink: /pages/56c077/
categories:
  - Java后端
  - 开源项目学习
tags:
  - 
---
# Github上开源电商系统mall 的学习

## 前言

本来是打算按目录下的结构来学习的，突然发现这样下来整体学习下来对自己而言思路不清晰，所以就想的怎样可以更清晰一些，方便地去了解，熟悉整个业务，整体项目。该项目本来就是前后端分离的项目，思考下来有两种方式：从前往后（前台到后台），从后往前（后台到前台），这样可能更容易理解，欢迎各位大佬指教。

## 后台整体项目的结构

首先，整体看看项目的结构，看看有哪些模块，见名知意，大概清楚自己想看的功能逻辑在哪个包下。



![image-20201202201051016](https://gitee.com/claa/tuci/raw/master/img/image-20201202201051016.png)

```
mall
├── mall-common -- 工具类及通用代码
├── mall-mbg -- MyBatisGenerator生成的数据库操作代码
├── mall-security -- SpringSecurity封装公用模块
├── mall-admin -- 后台商城管理系统接口
├── mall-search -- 基于Elasticsearch的商品搜索系统
├── mall-portal -- 前台商城系统接口
└── mall-demo -- 框架搭建时的测试代码
```

[mall在github上的源码](https://github.com/macrozheng/mall)

[mall在Windows 环境下的部署](http://www.macrozheng.com/#/deploy/mall_deploy_windows)

## 前台整体项目的结构



![image-20201208220902059](https://gitee.com/claa/tuci/raw/master/img/image-20201208220902059.png)

```
src -- 源码目录
├── api -- axios网络请求定义
├── assets -- 静态图片资源文件
├── components -- 通用组件封装
├── icons -- svg矢量图片文件
├── router -- vue-router路由配置
├── store -- vuex的状态管理
├── styles -- 全局css样式
├── utils -- 工具类
└── views -- 前端页面
    ├── home -- 首页
    ├── layout -- 通用页面加载框架
    ├── login -- 登录页
    ├── oms -- 订单模块页面
    ├── pms -- 商品模块页面
    └── sms -- 营销模块页面
```

[mall-admin-web在github上的源码](https://github.com/macrozheng/mall-admin-web)

[mall前端项目的安装与部署](http://www.macrozheng.com/#/deploy/mall_deploy_web?id=%e4%bb%8eidea%e4%b8%ad%e6%89%93%e5%bc%80mall-admin-web%e9%a1%b9%e7%9b%ae)

最后在本地启动服务后的效果：

![image-20201208221844672](https://gitee.com/claa/tuci/raw/master/img/image-20201208221844672.png)



以下是学习各个业务的文章：





# 订单相关的业务学习

首先，我们先整体看一下com.macro.mall 包下面的结构，不知道大家之前有没有学习过mvc 模式或者开发过项目，感觉和自己项目的整体结构还是有些类似的，我们接下来仔细看看。

## mall-admin 后台商城管理系统接口

![image-20201202213207712](https://gitee.com/claa/tuci/raw/master/img/image-20201202213207712.png)

```
com.macro.mall
├── bo -- 工具类及通用代码
├── component -- 切面组件
├── config --    配置层
├── controller -- 控制层
├── dao -- （data access object  数据访问对象，访问数据库的接口）
├── dto --（data transfer object 数据传输对象，接口之间传递的数据封装，具体的可以看参考文章）
├── service -- 服务层
└── validator -- 校验层
```



## DTO

我们先来认识一下订单业务相关的DTO。

你会发现这个文件夹下的所有类的变量只是后台数据库表中的一部分，其实这就是DTO的产生的意义，一是提高了数据传输的速度（减少了传输字段），二是隐藏了后端表的结构。

### OmsMoneyInfoParam修改订单费用信息参数(oms_order)

```java
/**
 * 修改订单费用信息参数
 * Created by macro on 2018/10/29.
 */
@Getter
@Setter
public class OmsMoneyInfoParam {
    @ApiModelProperty("订单ID")
    private Long orderId;
    @ApiModelProperty("运费金额")
    private BigDecimal freightAmount;
    @ApiModelProperty("管理员后台调整订单使用的折扣金额")
    private BigDecimal discountAmount;
    @ApiModelProperty("订单状态：0->待付款；1->待发货；2->已发货；3->已完成；4->已关闭；5->无效订单")
    private Integer status;
}
```



### OmsOrderDeliveryParam订单发货参数(oms_order)

```java
/**
 * 订单发货参数
 * Created by macro on 2018/10/12.
 */
@Getter
@Setter
public class OmsOrderDeliveryParam {
    @ApiModelProperty("订单id")
    private Long orderId;
    @ApiModelProperty("物流公司")
    private String deliveryCompany;
    @ApiModelProperty("物流单号")
    private String deliverySn;
}
```

### OmsOrderDetail订单详情信息(oms_order_item、oms_order_operate_history)

```java
/**
 * 订单详情信息
 * Created by macro on 2018/10/11.
 */
public class OmsOrderDetail extends OmsOrder {
    @Getter
    @Setter
    @ApiModelProperty("订单商品列表")
    private List<OmsOrderItem> orderItemList;
    @Getter
    @Setter
    @ApiModelProperty("订单操作记录列表")
    private List<OmsOrderOperateHistory> historyList;
}
```



### OmsOrderQueryParam 订单查询参数(oms_order)

```java
/**
 * 订单查询参数
 * Created by macro on 2018/10/11.
 */
@Getter
@Setter
public class OmsOrderQueryParam {
    @ApiModelProperty(value = "订单编号")
    private String orderSn;
    @ApiModelProperty(value = "收货人姓名/号码")
    private String receiverKeyword;
    @ApiModelProperty(value = "订单状态：0->待付款；1->待发货；2->已发货；3->已完成；4->已关闭；5->无效订单")
    private Integer status;
    @ApiModelProperty(value = "订单类型：0->正常订单；1->秒杀订单")
    private Integer orderType;
    @ApiModelProperty(value = "订单来源：0->PC订单；1->app订单")
    private Integer sourceType;
    @ApiModelProperty(value = "订单提交时间")
    private String createTime;
}

```



### OmsReceiverInfoParam订单修改收货人信息参数(oms_order)

```java
**
 * 订单修改收货人信息参数
 * Created by macro on 2018/10/29.
 */
@Getter
@Setter
public class OmsReceiverInfoParam {
    @ApiModelProperty(value = "订单ID")
    private Long orderId;
    @ApiModelProperty(value = "收货人姓名")
    private String receiverName;
    @ApiModelProperty(value = "收货人电话")
    private String receiverPhone;
    @ApiModelProperty(value = "收货人邮编")
    private String receiverPostCode;
    @ApiModelProperty(value = "详细地址")
    private String receiverDetailAddress;
    @ApiModelProperty(value = "省份/直辖市")
    private String receiverProvince;
    @ApiModelProperty(value = "城市")
    private String receiverCity;
    @ApiModelProperty(value = "区")
    private String receiverRegion;
    @ApiModelProperty(value = "订单状态：0->待付款；1->待发货；2->已发货；3->已完成；4->已关闭；5->无效订单")
    private Integer status;
}
```



### OmsOrderReturnApplyResult 申请信息封装(oms_order_return_apply)

```java
**
 * 申请信息封装
 * Created by macro on 2018/10/18.
 */
public class OmsOrderReturnApplyResult extends OmsOrderReturnApply {
    @Getter
    @Setter
    @ApiModelProperty(value = "公司收货地址")
    private OmsCompanyAddress companyAddress;
}
```



### OmsReturnApplyQueryParam订单退货申请查询参数(oms_order_return_apply)

```java
/**
 * 订单退货申请查询参数
 * Created by macro on 2018/10/18.
 */
@Getter
@Setter
public class OmsReturnApplyQueryParam {
    @ApiModelProperty("服务单号")
    private Long id;
    @ApiModelProperty(value = "收货人姓名/号码")
    private String receiverKeyword;
    @ApiModelProperty(value = "申请状态：0->待处理；1->退货中；2->已完成；3->已拒绝")
    private Integer status;
    @ApiModelProperty(value = "申请时间")
    private String createTime;
    @ApiModelProperty(value = "处理人员")
    private String handleMan;
    @ApiModelProperty(value = "处理时间")
    private String handleTime;
}
```

上面这些DTO，大家可以仔细的看看，后面具体的功能会大部分用到这些对象。

下面来具体聊聊订单相关的功能，先看看他们在前台的位置

![image-20201208224402954](https://gitee.com/claa/tuci/raw/master/img/image-20201208224402954.png)

以及代码里的位置：

![image-20201208224453824](https://gitee.com/claa/tuci/raw/master/img/image-20201208224453824.png)

## 订单列表功能

整体页面效果：（index.vue）

![image-20201209205642961](https://gitee.com/claa/tuci/raw/master/img/image-20201209205642961.png)



### 

### 筛选搜索&数据列表

#### 前台代码

##### index.vue



![image-20201209212445267](https://gitee.com/claa/tuci/raw/master/img/image-20201209212445267.png)

可以看到查询是调的fechList 方法，这个方法在哪里写的呢？

```vue
 # 调用路径
 import {fetchList,closeOrder,deleteOrder} from '@/api/order'
```

```js
import request from '@/utils/request'
export function fetchList(params) {
  return request({
    url:'/order/list',
    method:'get',
    params:params
  })
}

export function closeOrder(params) {
  return request({
    url:'/order/update/close',
    method:'post',
    params:params
  })
}

export function deleteOrder(params) {
  return request({
    url:'/order/delete',
    method:'post',
    params:params
  })
}

export function deliveryOrder(data) {
  return request({
    url:'/order/update/delivery',
    method:'post',
    data:data
  });
}

export function getOrderDetail(id) {
  return request({
    url:'/order/'+id,
    method:'get'
  });
}

export function updateReceiverInfo(data) {
  return request({
    url:'/order/update/receiverInfo',
    method:'post',
    data:data
  });
}

export function updateMoneyInfo(data) {
  return request({
    url:'/order/update/moneyInfo',
    method:'post',
    data:data
  });
}

export function updateOrderNote(params) {
  return request({
    url:'/order/update/note',
    method:'post',
    params:params
  })
}

```

可以看到以上的API请求，具体我们可以到swagger 上看详细的在线文档，可以通过[swagger在线文档](http://localhost:8080/swagger-ui.html)访问。

具体效果：

![image-20201209222055808](https://gitee.com/claa/tuci/raw/master/img/image-20201209222055808.png)

![image-20201209222243300](https://gitee.com/claa/tuci/raw/master/img/image-20201209222243300.png)

这里前后台实现数据交互的时候会有跨域的问题，可以查看

[前后端分离项目，如何解决跨域问题](http://www.macrozheng.com/#/technology/springboot_cors)

#### 后台代码

##### OmsOrderController

```java
@Controller
@Api(tags = "OmsOrderController", description = "订单管理")
@RequestMapping("/order")
public class OmsOrderController {
@ApiOperation("查询订单")
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<CommonPage<OmsOrder>> list(OmsOrderQueryParam queryParam,
                                                   @RequestParam(value = "pageSize", defaultValue = "5") Integer pageSize,
                                                   @RequestParam(value = "pageNum", defaultValue = "1") Integer pageNum) {
        List<OmsOrder> orderList = orderService.list(queryParam, pageSize, pageNum);
        return CommonResult.success(CommonPage.restPage(orderList));
    }
}
```

##### OmsOrderService

```java
public interface OmsOrderService {
    /**
     * 订单查询
     */
    List<OmsOrder> list(OmsOrderQueryParam queryParam, Integer pageSize, Integer pageNum);
    }
```

##### OmsOrderServiceImpl

```java
@Service
public class OmsOrderServiceImpl implements OmsOrderService
@Override
    public List<OmsOrder> list(OmsOrderQueryParam queryParam, Integer pageSize, Integer pageNum) {
        PageHelper.startPage(pageNum, pageSize);
        return orderDao.getList(queryParam);
    }
}
```

##### OmsOrderDao

```java
public interface OmsOrderDao {
    /**
     * 条件查询订单
     */
    List<OmsOrder> getList(@Param("queryParam") OmsOrderQueryParam queryParam);
    }
```



##### OmsOrderDao.xml 

```xml
<mapper namespace="com.macro.mall.dao.OmsOrderDao">
    <resultMap id="orderDetailResultMap" type="com.macro.mall.dto.OmsOrderDetail" extends="com.macro.mall.mapper.OmsOrderMapper.BaseResultMap">
        <collection property="orderItemList" resultMap="com.macro.mall.mapper.OmsOrderItemMapper.BaseResultMap" columnPrefix="item_"/>
        <collection property="historyList" resultMap="com.macro.mall.mapper.OmsOrderOperateHistoryMapper.BaseResultMap" columnPrefix="history_"/>
    </resultMap>
    <select id="getList" resultMap="com.macro.mall.mapper.OmsOrderMapper.BaseResultMap">
        SELECT *
        FROM
        oms_order
        WHERE
        delete_status = 0
        <if test="queryParam.orderSn!=null and queryParam.orderSn!=''">
            AND order_sn = #{queryParam.orderSn}
        </if>
        <if test="queryParam.status!=null">
            AND `status` = #{queryParam.status}
        </if>
        <if test="queryParam.sourceType!=null">
            AND source_type = #{queryParam.sourceType}
        </if>
        <if test="queryParam.orderType!=null">
            AND order_type = #{queryParam.orderType}
        </if>
        <if test="queryParam.createTime!=null and queryParam.createTime!=''">
            AND create_time LIKE concat(#{queryParam.createTime},"%")
        </if>
        <if test="queryParam.receiverKeyword!=null and queryParam.receiverKeyword!=''">
            AND (
            receiver_name LIKE concat("%",#{queryParam.receiverKeyword},"%")
            OR receiver_phone LIKE concat("%",#{queryParam.receiverKeyword},"%")
            )
        </if>
    </select>
    <mapper>
```

至此，就完成了一次搜索查询，从前台到后台，思路是不是清晰了一些。

### 查看订单

#### 效果图

![image-20201210201251742](https://gitee.com/claa/tuci/raw/master/img/image-20201210201251742.png)





#### 前台代码

```vue
<el-table-column label="操作" width="200" align="center">
  <template slot-scope="scope">
    <el-button
      size="mini"
      @click="handleViewOrder(scope.$index, scope.row)"
    >查看订单</el-button>
  </template>
</el-table-column>

scope.$index→拿到每一行的index
scope.$row→拿到每一行的数据
```

```vue
 handleViewOrder(index, row){
        this.$router.push({path:'/oms/orderDetail',query:{id:row.id}})
      },
```

![image-20201210203125745](https://gitee.com/claa/tuci/raw/master/img/image-20201210203125745.png)

```js
export function getOrderDetail(id) {
  return request({
    url:'/order/'+id,
    method:'get'
  });
}
```



#### 后台代码

##### OmsOrderController

```java
@Controller
@Api(tags = "OmsOrderController", description = "订单管理")
@RequestMapping("/order")
public class OmsOrderController {
    @ApiOperation("获取订单详情:订单信息、商品信息、操作记录")
    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<OmsOrderDetail> detail(@PathVariable Long id) {
        OmsOrderDetail orderDetailResult = orderService.detail(id);
        return CommonResult.success(orderDetailResult);
    }
}
```

##### OmsOrderService

```java
public interface OmsOrderService {
   /**
     * 获取指定订单详情
     */
    OmsOrderDetail detail(Long id);
    }
```

##### OmsOrderServiceImpl

```java
@Service
public class OmsOrderServiceImpl implements OmsOrderService{
 @Override
    public OmsOrderDetail detail(Long id) {
        return orderDao.getDetail(id);
    }
}
```

##### OmsOrderDao

```java
public interface OmsOrderDao {
   /**
     * 获取订单详情
     */
    OmsOrderDetail getDetail(@Param("id") Long id);
    }
}
```



##### OmsOrderDao.xml 

```xml
<mapper namespace="com.macro.mall.dao.OmsOrderDao">
    <resultMap id="orderDetailResultMap" type="com.macro.mall.dto.OmsOrderDetail" extends="com.macro.mall.mapper.OmsOrderMapper.BaseResultMap">
        <collection property="orderItemList" resultMap="com.macro.mall.mapper.OmsOrderItemMapper.BaseResultMap" columnPrefix="item_"/>
        <collection property="historyList" resultMap="com.macro.mall.mapper.OmsOrderOperateHistoryMapper.BaseResultMap" columnPrefix="history_"/>
    </resultMap>
    <select id="getDetail" resultMap="orderDetailResultMap">
        SELECT o.*,
            oi.id item_id,
            oi.product_id item_product_id,
            oi.product_sn item_product_sn,
            oi.product_pic item_product_pic,
            oi.product_name item_product_name,
            oi.product_brand item_product_brand,
            oi.product_price item_product_price,
            oi.product_quantity item_product_quantity,
            oi.product_attr item_product_attr,
            oh.id history_id,
            oh.operate_man history_operate_man,
            oh.create_time history_create_time,
            oh.order_status history_order_status,
            oh.note history_note
        FROM
            oms_order o
            LEFT JOIN oms_order_item oi ON o.id = oi.order_id
            LEFT JOIN oms_order_operate_history oh ON o.id = oh.order_id
        WHERE
            o.id = #{id}
        ORDER BY oi.id ASC,oh.create_time DESC
    </select>
  <mapper>
```

至此，订单详情完成。



### 删除订单& 批量删除

#### 效果图

![image-20201210205032050](https://gitee.com/claa/tuci/raw/master/img/image-20201210205032050.png)



![image-20201210214232466](https://gitee.com/claa/tuci/raw/master/img/image-20201210214232466.png)

#### 前台代码

```vue
<el-table-column label="操作" width="200" align="center">
  <template slot-scope="scope">
    <el-button
      size="mini"
      type="danger"
      @click="handleDeleteOrder(scope.$index, scope.row)"
      v-show="scope.row.status===4">删除订单</el-button>
  </template>
</el-table-column>
```

```js
 handleDeleteOrder(index, row){
        let ids=[];
        ids.push(row.id);
        this.deleteOrder(ids);
      },

          
  deleteOrder(ids){
        this.$confirm('是否要进行该删除操作?', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          let params = new URLSearchParams();
          params.append("ids",ids);
          deleteOrder(params).then(response=>{
            this.$message({
              message: '删除成功！',
              type: 'success',
              duration: 1000
            });
            this.getList();
          });
        })
      },
```

```js
export function deleteOrder(params) {
  return request({
    url:'/order/delete',
    method:'post',
    params:params
  })
}
```

#### 后台代码

##### OmsOrderController

```java
@Controller
@Api(tags = "OmsOrderController", description = "订单管理")
@RequestMapping("/order")
public class OmsOrderController {
 @ApiOperation("批量删除订单")
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult delete(@RequestParam("ids") List<Long> ids) {
        int count = orderService.delete(ids);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }
}
```

##### OmsOrderService

```java
public interface OmsOrderService {
  /**
     * 批量删除订单
     */
    int delete(List<Long> ids);
}
```

##### OmsOrderServiceImpl

```java
@Service
public class OmsOrderServiceImpl implements OmsOrderService{
@Override
    public int delete(List<Long> ids) {
        OmsOrder record = new OmsOrder();
        record.setDeleteStatus(1);
        OmsOrderExample example = new OmsOrderExample();
        example.createCriteria().andDeleteStatusEqualTo(0).andIdIn(ids);
        return orderMapper.updateByExampleSelective(record, example);
    }
}
```

##### OmsOrderExample和orderMapper

这两个文件是myBatis generate ，逆向工程。

至此，删除订单完成。



### 订单发货&保存历史操作

#### 效果图

![image-20201210214808448](https://gitee.com/claa/tuci/raw/master/img/image-20201210214808448.png)



#### 前台代码

```vue
<el-table-column label="操作" width="200" align="center">
  <template slot-scope="scope">
    <el-button
      size="mini"
      @click="handleDeliveryOrder(scope.$index, scope.row)"
      v-show="scope.row.status===1">订单发货</el-button>
  </template>
</el-table-column>
```

```
handleDeliveryOrder(index, row){
        let listItem = this.covertOrder(row);
        this.$router.push({path:'/oms/deliverOrderList',query:{list:[listItem]}})
      },
```

```js
export function deliveryOrder(data) {
  return request({
    url:'/order/update/delivery',
    method:'post',
    data:data
  });
}
```

```vue
methods:{
      cancel(){
        this.$router.back();
      },
      confirm(){
        this.$confirm('是否要进行发货操作?', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          deliveryOrder(this.list).then(response=>{
            this.$router.back();
            this.$message({
              type: 'success',
              message: '发货成功!'
            });
          });
        }).catch(() => {
          this.$message({
            type: 'info',
            message: '已取消发货'
          });
        });
      }
    }
```



#### 后台代码

##### OmsOrderController

```java
@Controller
@Api(tags = "OmsOrderController", description = "订单管理")
@RequestMapping("/order")
public class OmsOrderController {
    @ApiOperation("批量发货")
    @RequestMapping(value = "/update/delivery", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult delivery(@RequestBody List<OmsOrderDeliveryParam> deliveryParamList) {
        int count = orderService.delivery(deliveryParamList);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }
}
```

##### OmsOrderService

```java
public interface OmsOrderService {
    /**
     * 批量发货
     */
    @Transactional
    int delivery(List<OmsOrderDeliveryParam> deliveryParamList);
}
```

##### OmsOrderServiceImpl

```java
@Service
public class OmsOrderServiceImpl implements OmsOrderService{
  @Override
    public int delivery(List<OmsOrderDeliveryParam> deliveryParamList) {
        //批量发货
        int count = orderDao.delivery(deliveryParamList);
        //添加操作记录
        List<OmsOrderOperateHistory> operateHistoryList = deliveryParamList.stream()
                .map(omsOrderDeliveryParam -> {
                    OmsOrderOperateHistory history = new OmsOrderOperateHistory();
                    history.setOrderId(omsOrderDeliveryParam.getOrderId());
                    history.setCreateTime(new Date());
                    history.setOperateMan("后台管理员");
                    history.setOrderStatus(2);
                    history.setNote("完成发货");
                    return history;
                }).collect(Collectors.toList());
        orderOperateHistoryDao.insertList(operateHistoryList);
        return count;
    }
}
```

这里是使用的stream() 的map方法 ，为集合创建串行流，并为集合中每个对象修改发货完成的状态信息。

具体用法参考：

map 方法用于映射每个元素到对应的结果，以下代码片段使用 map 输出了元素对应的平方数：

```java
List<Integer> numbers = Arrays.asList(3, 2, 2, 3, 7, 3, 5);
// 获取对应的平方数
List<Integer> squaresList = numbers.stream().map( i -> i*i).distinct().collect(Collectors.toList());
```



```java
 public interface OmsOrderDao {
 /**
     * 批量发货
     */
    int delivery(@Param("list") List<OmsOrderDeliveryParam> deliveryParamList);
 }
```

##### OmsOrderOperateHistoryDao

```java
public interface OmsOrderOperateHistoryDao {
    /**
     * 批量创建
     */
    int insertList(@Param("list") List<OmsOrderOperateHistory> orderOperateHistoryList);
}
```



##### OmsOrderDao.xml 

```xml
<mapper namespace="com.macro.mall.dao.OmsOrderDao">
    <resultMap id="orderDetailResultMap" type="com.macro.mall.dto.OmsOrderDetail" extends="com.macro.mall.mapper.OmsOrderMapper.BaseResultMap">
        <collection property="orderItemList" resultMap="com.macro.mall.mapper.OmsOrderItemMapper.BaseResultMap" columnPrefix="item_"/>
        <collection property="historyList" resultMap="com.macro.mall.mapper.OmsOrderOperateHistoryMapper.BaseResultMap" columnPrefix="history_"/>
    </resultMap>
    <update id="delivery">
        UPDATE oms_order
        SET
        delivery_sn = CASE id
        <foreach collection="list" item="item">
            WHEN #{item.orderId} THEN #{item.deliverySn}
        </foreach>
        END,
        delivery_company = CASE id
        <foreach collection="list" item="item">
            WHEN #{item.orderId} THEN #{item.deliveryCompany}
        </foreach>
        END,
        delivery_time = CASE id
        <foreach collection="list" item="item">
            WHEN #{item.orderId} THEN now()
        </foreach>
        END,
        `status` = CASE id
        <foreach collection="list" item="item">
            WHEN #{item.orderId} THEN 2
        </foreach>
        END
        WHERE
        id IN
        <foreach collection="list" item="item" separator="," open="(" close=")">
            #{item.orderId}
        </foreach>
        AND `status` = 1
    </update>
  <mapper>
```



##### OmsOrderOperateHistoryDao.xml

```xml
<mapper namespace="com.macro.mall.dao.OmsOrderOperateHistoryDao">
    <insert id="insertList">
        INSERT INTO oms_order_operate_history (order_id, operate_man, create_time, order_status, note) VALUES
        <foreach collection="list" separator="," item="item" index="index">
            (#{item.orderId},
            #{item.operateMan},
            #{item.createTime,jdbcType=TIMESTAMP},
            #{item.orderStatus},
            #{item.note})
        </foreach>
    </insert>
</mapper>
```



至此，订单发货以及历史记录操作保存功能完成。





### 订单跟踪

##### 效果图

![image-20201212103055569](https://gitee.com/claa/tuci/raw/master/img/image-20201212103055569.png)

##### 前台代码

```vue
<el-table-column label="操作" width="200" align="center">
  <template slot-scope="scope">
    <el-button
      size="mini"
      @click="handleViewLogistics(scope.$index, scope.row)"
      v-show="scope.row.status===2||scope.row.status===3">订单跟踪</el-button>
  </template>
</el-table-column>
```

```js
 handleViewLogistics(index, row){
        this.logisticsDialogVisible=true;
      },
```

![image-20201212103628895](https://gitee.com/claa/tuci/raw/master/img/image-20201212103628895.png)

一开始是隐藏的效果，只有点击订单跟踪这个按钮后，就会显示订单这个详情框。

```vue
<el-dialog title="订单跟踪"
             :visible.sync="visible"
             :before-close="handleClose"
             width="40%">
    <el-steps direction="vertical"
              :active="6"
              finish-status="success"
              space="50px">
      <el-step  v-for="item in logisticsList"
                :key="item.name"
                :title="item.name"
                :description="item.time"></el-step>
    </el-steps>
  </el-dialog>
</template>
<script>
  const defaultLogisticsList=[
    {name: '订单已提交，等待付款',time:'2017-04-01 12:00:00 '},
    {name: '订单付款成功',time:'2017-04-01 12:00:00 '},
    {name: '在北京市进行下级地点扫描，等待付款',time:'2017-04-01 12:00:00 '},
    {name: '在分拨中心广东深圳公司进行卸车扫描，等待付款',time:'2017-04-01 12:00:00 '},
    {name: '在广东深圳公司进行发出扫描',time:'2017-04-01 12:00:00 '},
    {name: '到达目的地网点广东深圳公司，快件将很快进行派送',time:'2017-04-01 12:00:00 '},
    {name: '订单已签收，期待再次为您服务',time:'2017-04-01 12:00:00 '}
  ];
  export default {
    name:'logisticsDialog',
    props: {
      value: Boolean
    },
    computed:{
      visible: {
        get() {
          return this.value;
        },
        set(visible){
          this.value=visible;
        }
      }
    },
    data() {
      return {
        logisticsList:Object.assign({},defaultLogisticsList)
      }
    },
    methods:{
      emitInput(val) {
        this.$emit('input', val)
      },
      handleClose(){
        this.emitInput(false);
      }
    }
  }
</script>
```



#####  后台代码

开源项目中写的是静态代码，没有保存到数据库。

### 关闭订单

##### 效果图

![image-20201212111641665](https://gitee.com/claa/tuci/raw/master/img/image-20201212111641665.png)



##### 前台代码

```vue
<el-table-column label="操作" width="200" align="center">
  <template slot-scope="scope">
    <el-button
      size="mini"
      @click="handleCloseOrder(scope.$index, scope.row)"
      v-show="scope.row.status===0">关闭订单</el-button>
  </template>
</el-table-column>
```

```
<el-dialog
      title="关闭订单"
      :visible.sync="closeOrder.dialogVisible" width="30%">
      <span style="vertical-align: top">操作备注：</span>
      <el-input
        style="width: 80%"
        type="textarea"
        :rows="5"
        placeholder="请输入内容"
        v-model="closeOrder.content">
      </el-input>
      <span slot="footer" class="dialog-footer">
        <el-button @click="closeOrder.dialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="handleCloseOrderConfirm">确 定</el-button>
      </span>
    </el-dialog>
```

```js
 handleCloseOrderConfirm() {
        if (this.closeOrder.content == null || this.closeOrder.content === '') {
          this.$message({
            message: '操作备注不能为空',
            type: 'warning',
            duration: 1000
          });
          return;
        }
        let params = new URLSearchParams();
        params.append('ids', this.closeOrder.orderIds);
        params.append('note', this.closeOrder.content);
        closeOrder(params).then(response=>{
          this.closeOrder.orderIds=[];
          this.closeOrder.dialogVisible=false;
          this.getList();
          this.$message({
            message: '修改成功',
            type: 'success',
            duration: 1000
          });
        });
      },
```

```js
export function closeOrder(params) {
  return request({
    url:'/order/update/close',
    method:'post',
    params:params
  })
}
```



##### 后台代码

##### OmsOrderController

```java
@Controller
@Api(tags = "OmsOrderController", description = "订单管理")
@RequestMapping("/order")
public class OmsOrderController {
   @ApiOperation("批量关闭订单")
    @RequestMapping(value = "/update/close", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult close(@RequestParam("ids") List<Long> ids, @RequestParam String note) {
        int count = orderService.close(ids, note);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }
}
```

##### OmsOrderService

```java
public interface OmsOrderService {
   /**
     * 批量关闭订单
     */
    @Transactional
    int close(List<Long> ids, String note);
}
```

##### OmsOrderServiceImpl

```java
@Service
public class OmsOrderServiceImpl implements OmsOrderService{
  @Override
    public int close(List<Long> ids, String note) {
        OmsOrder record = new OmsOrder();
        record.setStatus(4);
        OmsOrderExample example = new OmsOrderExample();
        example.createCriteria().andDeleteStatusEqualTo(0).andIdIn(ids);
        int count = orderMapper.updateByExampleSelective(record, example);
        List<OmsOrderOperateHistory> historyList = ids.stream().map(orderId -> {
            OmsOrderOperateHistory history = new OmsOrderOperateHistory();
            history.setOrderId(orderId);
            history.setCreateTime(new Date());
            history.setOperateMan("后台管理员");
            history.setOrderStatus(4);
            history.setNote("订单关闭:"+note);
            return history;
        }).collect(Collectors.toList());
        orderOperateHistoryDao.insertList(historyList);
        return count;
    }
}
```

##### orderMapper 

mybatis  逆向自动生成的

##### OmsOrderOperateHistoryDao.xml

```xml
<mapper namespace="com.macro.mall.dao.OmsOrderOperateHistoryDao">
    <insert id="insertList">
        INSERT INTO oms_order_operate_history (order_id, operate_man, create_time, order_status, note) VALUES
        <foreach collection="list" separator="," item="item" index="index">
            (#{item.orderId},
            #{item.operateMan},
            #{item.createTime,jdbcType=TIMESTAMP},
            #{item.orderStatus},
            #{item.note})
        </foreach>
    </insert>
</mapper>
```



### 分页

##### 效果图

![image-20201212113734715](https://gitee.com/claa/tuci/raw/master/img/image-20201212113734715.png)



##### 前台代码

```vue
<div class="pagination-container">
      <el-pagination
        background
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        layout="total, sizes,prev, pager, next,jumper"
        :current-page.sync="listQuery.pageNum"
        :page-size="listQuery.pageSize"
        :page-sizes="[5,10,15]"
        :total="total">
      </el-pagination>
    </div>
```

```js
 handleSizeChange(val){
        this.listQuery.pageNum = 1;
        this.listQuery.pageSize = val;
        this.getList();
      },
      handleCurrentChange(val){
        this.listQuery.pageNum = val;
        this.getList();
      },
```



##### 后台代码

用的是mybatis 中pagehelper 插件.

```java
 @Override
    public List<OmsOrder> list(OmsOrderQueryParam queryParam, Integer pageSize, Integer pageNum) {
        PageHelper.startPage(pageNum, pageSize);
        return orderDao.getList(queryParam);
    }
```

下面是配置文件：

```xml
#pagehelper分页插件配置
pagehelper.helperDialect=mysql
pagehelper.reasonable=true
pagehelper.supportMethodsArguments=true
pagehelper.params=count=countSql
```



## 订单设置功能

##### 效果图

![image-20201212155751277](https://gitee.com/claa/tuci/raw/master/img/image-20201212155751277.png)

##### 前台代码

```vue
<template> 
  <el-card class="form-container" shadow="never">
    <el-form :model="orderSetting"
             ref="orderSettingForm"
             :rules="rules"
             label-width="150px">
      <el-form-item label="秒杀订单超过：" prop="flashOrderOvertime">
        <el-input v-model="orderSetting.flashOrderOvertime" class="input-width">
          <template slot="append">分</template>
        </el-input>
        <span class="note-margin">未付款，订单自动关闭</span>
      </el-form-item>
      <el-form-item label="正常订单超过：" prop="normalOrderOvertime">
        <el-input v-model="orderSetting.normalOrderOvertime" class="input-width">
          <template slot="append">分</template>
        </el-input>
        <span class="note-margin">未付款，订单自动关闭</span>
      </el-form-item>
      <el-form-item label="发货超过：" prop="confirmOvertime">
        <el-input v-model="orderSetting.confirmOvertime" class="input-width">
          <template slot="append">天</template>
        </el-input>
        <span class="note-margin">未收货，订单自动完成</span>
      </el-form-item>
      <el-form-item label="订单完成超过：" prop="finishOvertime">
        <el-input v-model="orderSetting.finishOvertime" class="input-width">
          <template slot="append">天</template>
        </el-input>
        <span class="note-margin">自动结束交易，不能申请售后</span>
      </el-form-item>
      <el-form-item label="订单完成超过：" prop="commentOvertime">
        <el-input v-model="orderSetting.commentOvertime" class="input-width">
          <template slot="append">天</template>
        </el-input>
        <span class="note-margin">自动五星好评</span>
      </el-form-item>
      <el-form-item>
        <el-button
          @click="confirm('orderSettingForm')"
          type="primary">提交</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>
<script>
  import {getOrderSetting,updateOrderSetting} from '@/api/orderSetting';
  const defaultOrderSetting = {
    id: null,
    flashOrderOvertime: 0,
    normalOrderOvertime: 0,
    confirmOvertime: 0,
    finishOvertime: 0,
    commentOvertime: 0
  };
  const checkTime = (rule, value, callback) => {
    if (!value) {
      return callback(new Error('时间不能为空'));
    }
    console.log("checkTime",value);
    let intValue = parseInt(value);
    if (!Number.isInteger(intValue)) {
      return callback(new Error('请输入数字值'));
    }
    callback();
  };
  export default {
    name: 'orderSetting',
    data() {
      return {
        orderSetting: Object.assign({}, defaultOrderSetting),
        rules: {
          flashOrderOvertime:{validator: checkTime, trigger: 'blur' },
          normalOrderOvertime:{validator: checkTime, trigger: 'blur' },
          confirmOvertime: {validator: checkTime, trigger: 'blur' },
          finishOvertime: {validator: checkTime, trigger: 'blur' },
          commentOvertime:{validator: checkTime, trigger: 'blur' }
        }
      }
    },
    created(){
      this.getDetail();
    },
    methods:{
      confirm(formName){
        this.$refs[formName].validate((valid) => {
          if (valid) {
            this.$confirm('是否要提交修改?', '提示', {
              confirmButtonText: '确定',
              cancelButtonText: '取消',
              type: 'warning'
            }).then(() => {
              updateOrderSetting(1,this.orderSetting).then(response=>{
                this.$message({
                  type: 'success',
                  message: '提交成功!',
                  duration:1000
                });
              })
            });
          } else {
            this.$message({
              message: '提交参数不合法',
              type: 'warning'
            });
            return false;
          }
        });
      },
      getDetail(){
        getOrderSetting(1).then(response=>{
          this.orderSetting=response.data;
        })
      }
    }
  }
</script>
<style scoped>
  .input-width {
    width: 50%;
  }

  .note-margin {
    margin-left: 15px;
  }
</style>



```

有数据校验功能，主要是对空值以及非数值的检验。

```js
export function getOrderSetting(id) {
  return request({
    url:'/orderSetting/'+id,
    method:'get',
  })
}

export function updateOrderSetting(id,data) {
  return request({
    url:'/orderSetting/update/'+id,
    method:'post',
    data:data
  })
}
```



##### 后台代码

##### OmsOrderSettingController

```java
@Controller
@Api(tags = "OmsOrderSettingController", description = "订单设置管理")
@RequestMapping("/orderSetting")
public class OmsOrderSettingController {
    @Autowired
    private OmsOrderSettingService orderSettingService;

    @ApiOperation("获取指定订单设置")
    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<OmsOrderSetting> getItem(@PathVariable Long id) {
        OmsOrderSetting orderSetting = orderSettingService.getItem(id);
        return CommonResult.success(orderSetting);
    }

    @ApiOperation("修改指定订单设置")
    @RequestMapping(value = "/update/{id}", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult update(@PathVariable Long id, @RequestBody OmsOrderSetting orderSetting) {
        int count = orderSettingService.update(id,orderSetting);
        if(count>0){
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }
}

```



##### OmsOrderSettingService

```java
public interface OmsOrderSettingService {
    /**
     * 获取指定订单设置
     */
    OmsOrderSetting getItem(Long id);

    /**
     * 修改指定订单设置
     */
    int update(Long id, OmsOrderSetting orderSetting);
}
```



#####  OmsOrderSettingServiceImpl

```java
@Service
public class OmsOrderSettingServiceImpl implements OmsOrderSettingService {
    @Autowired
    private OmsOrderSettingMapper orderSettingMapper;

    @Override
    public OmsOrderSetting getItem(Long id) {
        return orderSettingMapper.selectByPrimaryKey(id);
    }

    @Override
    public int update(Long id, OmsOrderSetting orderSetting) {
        orderSetting.setId(id);
        return orderSettingMapper.updateByPrimaryKey(orderSetting);
    }
}
```



##### OmsOrderSettingMapper

```java
public interface OmsOrderSettingMapper {
    long countByExample(OmsOrderSettingExample example);

    int deleteByExample(OmsOrderSettingExample example);

    int deleteByPrimaryKey(Long id);

    int insert(OmsOrderSetting record);

    int insertSelective(OmsOrderSetting record);

    List<OmsOrderSetting> selectByExample(OmsOrderSettingExample example);

    OmsOrderSetting selectByPrimaryKey(Long id);

    int updateByExampleSelective(@Param("record") OmsOrderSetting record, @Param("example") OmsOrderSettingExample example);

    int updateByExample(@Param("record") OmsOrderSetting record, @Param("example") OmsOrderSettingExample example);

    int updateByPrimaryKeySelective(OmsOrderSetting record);

    int updateByPrimaryKey(OmsOrderSetting record);
}
```



## 退货申请处理功能

##### 效果图

![image-20201212155823367](https://gitee.com/claa/tuci/raw/master/img/image-20201212155910752.png)

##### 前台代码

```js
export function fetchList(params) {
  return request({
    url:'/returnApply/list',
    method:'get',
    params:params
  })
}

export function deleteApply(params) {
  return request({
    url:'/returnApply/delete',
    method:'post',
    params:params
  })
}
export function updateApplyStatus(id,data) {
  return request({
    url:'/returnApply/update/status/'+id,
    method:'post',
    data:data
  })
}

export function getApplyDetail(id) {
  return request({
    url:'/returnApply/'+id,
    method:'get'
  })
}
```



##### 后台代码

##### OmsOrderReturnApplyController

```java
@Controller
@Api(tags = "OmsOrderReturnApplyController", description = "订单退货申请管理")
@RequestMapping("/returnApply")
public class OmsOrderReturnApplyController {
    @Autowired
    private OmsOrderReturnApplyService returnApplyService;

    @ApiOperation("分页查询退货申请")
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<CommonPage<OmsOrderReturnApply>> list(OmsReturnApplyQueryParam queryParam,
                                                              @RequestParam(value = "pageSize", defaultValue = "5") Integer pageSize,
                                                              @RequestParam(value = "pageNum", defaultValue = "1") Integer pageNum) {
        List<OmsOrderReturnApply> returnApplyList = returnApplyService.list(queryParam, pageSize, pageNum);
        return CommonResult.success(CommonPage.restPage(returnApplyList));
    }

    @ApiOperation("批量删除申请")
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult delete(@RequestParam("ids") List<Long> ids) {
        int count = returnApplyService.delete(ids);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }

    @ApiOperation("获取退货申请详情")
    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult getItem(@PathVariable Long id) {
        OmsOrderReturnApplyResult result = returnApplyService.getItem(id);
        return CommonResult.success(result);
    }

    @ApiOperation("修改申请状态")
    @RequestMapping(value = "/update/status/{id}", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult updateStatus(@PathVariable Long id, @RequestBody OmsUpdateStatusParam statusParam) {
        int count = returnApplyService.updateStatus(id, statusParam);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }

}

```

##### OmsOrderReturnApplyService 

```
public interface OmsOrderReturnApplyService {
    /**
     * 分页查询申请
     */
    List<OmsOrderReturnApply> list(OmsReturnApplyQueryParam queryParam, Integer pageSize, Integer pageNum);

    /**
     * 批量删除申请
     */
    int delete(List<Long> ids);

    /**
     * 修改申请状态
     */
    int updateStatus(Long id, OmsUpdateStatusParam statusParam);

    /**
     * 获取指定申请详情
     */
    OmsOrderReturnApplyResult getItem(Long id);
}
```



##### OmsOrderReturnApplyServiceImpl

```java
@Service
public class OmsOrderReturnApplyServiceImpl implements OmsOrderReturnApplyService {
    @Autowired
    private OmsOrderReturnApplyDao returnApplyDao;
    @Autowired
    private OmsOrderReturnApplyMapper returnApplyMapper;
    @Override
    public List<OmsOrderReturnApply> list(OmsReturnApplyQueryParam queryParam, Integer pageSize, Integer pageNum) {
        PageHelper.startPage(pageNum,pageSize);
        return returnApplyDao.getList(queryParam);
    }

    @Override
    public int delete(List<Long> ids) {
        OmsOrderReturnApplyExample example = new OmsOrderReturnApplyExample();
        example.createCriteria().andIdIn(ids).andStatusEqualTo(3);
        return returnApplyMapper.deleteByExample(example);
    }

    @Override
    public int updateStatus(Long id, OmsUpdateStatusParam statusParam) {
        Integer status = statusParam.getStatus();
        OmsOrderReturnApply returnApply = new OmsOrderReturnApply();
        if(status.equals(1)){
            //确认退货
            returnApply.setId(id);
            returnApply.setStatus(1);
            returnApply.setReturnAmount(statusParam.getReturnAmount());
            returnApply.setCompanyAddressId(statusParam.getCompanyAddressId());
            returnApply.setHandleTime(new Date());
            returnApply.setHandleMan(statusParam.getHandleMan());
            returnApply.setHandleNote(statusParam.getHandleNote());
        }else if(status.equals(2)){
            //完成退货
            returnApply.setId(id);
            returnApply.setStatus(2);
            returnApply.setReceiveTime(new Date());
            returnApply.setReceiveMan(statusParam.getReceiveMan());
            returnApply.setReceiveNote(statusParam.getReceiveNote());
        }else if(status.equals(3)){
            //拒绝退货
            returnApply.setId(id);
            returnApply.setStatus(3);
            returnApply.setHandleTime(new Date());
            returnApply.setHandleMan(statusParam.getHandleMan());
            returnApply.setHandleNote(statusParam.getHandleNote());
        }else{
            return 0;
        }
        return returnApplyMapper.updateByPrimaryKeySelective(returnApply);
    }

    @Override
    public OmsOrderReturnApplyResult getItem(Long id) {
        return returnApplyDao.getDetail(id);
    }
}
```



## 退货原因设置功能

##### 效果图

![image-20201212155910752](https://gitee.com/claa/tuci/raw/master/img/image-20201212155910752.png)

##### 

##### 前台代码

```js
export function fetchList(params) {
  return request({
    url:'/returnReason/list',
    method:'get',
    params:params
  })
}

export function deleteReason(params) {
  return request({
    url:'/returnReason/delete',
    method:'post',
    params:params
  })
}

export function updateStatus(params) {
  return request({
    url:'/returnReason/update/status',
    method:'post',
    params:params
  })
}

export function addReason(data) {
  return request({
    url:'/returnReason/create',
    method:'post',
    data:data
  })
}

export function getReasonDetail(id) {
  return request({
    url:'/returnReason/'+id,
    method:'get'
  })
}

export function updateReason(id,data) {
  return request({
    url:'/returnReason/update/'+id,
    method:'post',
    data:data
  })
}

```



##### 后台代码



##### OmsOrderReturnReasonController

```
@Controller
@Api(tags = "OmsOrderReturnReasonController", description = "退货原因管理")
@RequestMapping("/returnReason")
public class OmsOrderReturnReasonController {
    @Autowired
    private OmsOrderReturnReasonService orderReturnReasonService;

    @ApiOperation("添加退货原因")
    @RequestMapping(value = "/create", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult create(@RequestBody OmsOrderReturnReason returnReason) {
        int count = orderReturnReasonService.create(returnReason);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }

    @ApiOperation("修改退货原因")
    @RequestMapping(value = "/update/{id}", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult update(@PathVariable Long id, @RequestBody OmsOrderReturnReason returnReason) {
        int count = orderReturnReasonService.update(id, returnReason);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }

    @ApiOperation("批量删除退货原因")
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult delete(@RequestParam("ids") List<Long> ids) {
        int count = orderReturnReasonService.delete(ids);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }

    @ApiOperation("分页查询全部退货原因")
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<CommonPage<OmsOrderReturnReason>> list(@RequestParam(value = "pageSize", defaultValue = "5") Integer pageSize,
                                                               @RequestParam(value = "pageNum", defaultValue = "1") Integer pageNum) {
        List<OmsOrderReturnReason> reasonList = orderReturnReasonService.list(pageSize, pageNum);
        return CommonResult.success(CommonPage.restPage(reasonList));
    }

    @ApiOperation("获取单个退货原因详情信息")
    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<OmsOrderReturnReason> getItem(@PathVariable Long id) {
        OmsOrderReturnReason reason = orderReturnReasonService.getItem(id);
        return CommonResult.success(reason);
    }

    @ApiOperation("修改退货原因启用状态")
    @RequestMapping(value = "/update/status", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult updateStatus(@RequestParam(value = "status") Integer status,
                                     @RequestParam("ids") List<Long> ids) {
        int count = orderReturnReasonService.updateStatus(ids, status);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed();
    }
}
```

##### OmsOrderReturnReasonService

```java
public interface OmsOrderReturnReasonService {
    /**
     * 添加订单原因
     */
    int create(OmsOrderReturnReason returnReason);

    /**
     * 修改退货原因
     */
    int update(Long id, OmsOrderReturnReason returnReason);

    /**
     * 批量删除退货原因
     */
    int delete(List<Long> ids);

    /**
     * 分页获取退货原因
     */
    List<OmsOrderReturnReason> list(Integer pageSize, Integer pageNum);

    /**
     * 批量修改退货原因状态
     */
    int updateStatus(List<Long> ids, Integer status);

    /**
     * 获取单个退货原因详情信息
     */
    OmsOrderReturnReason getItem(Long id);
}
```



##### OmsOrderReturnReasonServiceImpl

```java
@Service
public class OmsOrderReturnReasonServiceImpl implements OmsOrderReturnReasonService {
    @Autowired
    private OmsOrderReturnReasonMapper returnReasonMapper;
    @Override
    public int create(OmsOrderReturnReason returnReason) {
        returnReason.setCreateTime(new Date());
        return returnReasonMapper.insert(returnReason);
    }

    @Override
    public int update(Long id, OmsOrderReturnReason returnReason) {
        returnReason.setId(id);
        return returnReasonMapper.updateByPrimaryKey(returnReason);
    }

    @Override
    public int delete(List<Long> ids) {
        OmsOrderReturnReasonExample example = new OmsOrderReturnReasonExample();
        example.createCriteria().andIdIn(ids);
        return returnReasonMapper.deleteByExample(example);
    }

    @Override
    public List<OmsOrderReturnReason> list(Integer pageSize, Integer pageNum) {
        PageHelper.startPage(pageNum,pageSize);
        OmsOrderReturnReasonExample example = new OmsOrderReturnReasonExample();
        example.setOrderByClause("sort desc");
        return returnReasonMapper.selectByExample(example);
    }

    @Override
    public int updateStatus(List<Long> ids, Integer status) {
        if(!status.equals(0)&&!status.equals(1)){
            return 0;
        }
        OmsOrderReturnReason record = new OmsOrderReturnReason();
        record.setStatus(status);
        OmsOrderReturnReasonExample example = new OmsOrderReturnReasonExample();
        example.createCriteria().andIdIn(ids);
        return returnReasonMapper.updateByExampleSelective(record,example);
    }

    @Override
    public OmsOrderReturnReason getItem(Long id) {
        return returnReasonMapper.selectByPrimaryKey(id);
    }
}

```



## 相关表

### oms_order订单表

```mysql
CREATE TABLE `oms_order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单id',
  `member_id` bigint(20) NOT NULL COMMENT '会员id',
  `coupon_id` bigint(20) DEFAULT NULL COMMENT '优惠券id',
  `order_sn` varchar(64) DEFAULT NULL COMMENT '订单编号',
  `create_time` datetime DEFAULT NULL COMMENT '提交时间',
  `member_username` varchar(64) DEFAULT NULL COMMENT '用户帐号',
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '订单总金额',
  `pay_amount` decimal(10,2) DEFAULT NULL COMMENT '应付金额（实际支付金额）',
  `freight_amount` decimal(10,2) DEFAULT NULL COMMENT '运费金额',
  `promotion_amount` decimal(10,2) DEFAULT NULL COMMENT '促销优化金额（促销价、满减、阶梯价）',
  `integration_amount` decimal(10,2) DEFAULT NULL COMMENT '积分抵扣金额',
  `coupon_amount` decimal(10,2) DEFAULT NULL COMMENT '优惠券抵扣金额',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '管理员后台调整订单使用的折扣金额',
  `pay_type` int(1) DEFAULT NULL COMMENT '支付方式：0->未支付；1->支付宝；2->微信',
  `source_type` int(1) DEFAULT NULL COMMENT '订单来源：0->PC订单；1->app订单',
  `status` int(1) DEFAULT NULL COMMENT '订单状态：0->待付款；1->待发货；2->已发货；3->已完成；4->已关闭；5->无效订单',
  `order_type` int(1) DEFAULT NULL COMMENT '订单类型：0->正常订单；1->秒杀订单',
  `delivery_company` varchar(64) DEFAULT NULL COMMENT '物流公司(配送方式)',
  `delivery_sn` varchar(64) DEFAULT NULL COMMENT '物流单号',
  `auto_confirm_day` int(11) DEFAULT NULL COMMENT '自动确认时间（天）',
  `integration` int(11) DEFAULT NULL COMMENT '可以获得的积分',
  `growth` int(11) DEFAULT NULL COMMENT '可以活动的成长值',
  `promotion_info` varchar(100) DEFAULT NULL COMMENT '活动信息',
  `bill_type` int(1) DEFAULT NULL COMMENT '发票类型：0->不开发票；1->电子发票；2->纸质发票',
  `bill_header` varchar(200) DEFAULT NULL COMMENT '发票抬头',
  `bill_content` varchar(200) DEFAULT NULL COMMENT '发票内容',
  `bill_receiver_phone` varchar(32) DEFAULT NULL COMMENT '收票人电话',
  `bill_receiver_email` varchar(64) DEFAULT NULL COMMENT '收票人邮箱',
  `receiver_name` varchar(100) NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(32) NOT NULL COMMENT '收货人电话',
  `receiver_post_code` varchar(32) DEFAULT NULL COMMENT '收货人邮编',
  `receiver_province` varchar(32) DEFAULT NULL COMMENT '省份/直辖市',
  `receiver_city` varchar(32) DEFAULT NULL COMMENT '城市',
  `receiver_region` varchar(32) DEFAULT NULL COMMENT '区',
  `receiver_detail_address` varchar(200) DEFAULT NULL COMMENT '详细地址',
  `note` varchar(500) DEFAULT NULL COMMENT '订单备注',
  `confirm_status` int(1) DEFAULT NULL COMMENT '确认收货状态：0->未确认；1->已确认',
  `delete_status` int(1) NOT NULL DEFAULT '0' COMMENT '删除状态：0->未删除；1->已删除',
  `use_integration` int(11) DEFAULT NULL COMMENT '下单时使用的积分',
  `payment_time` datetime DEFAULT NULL COMMENT '支付时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `receive_time` datetime DEFAULT NULL COMMENT '确认收货时间',
  `comment_time` datetime DEFAULT NULL COMMENT '评价时间',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='单表，需要注意的是订单状态：0->待付款；1->待发货；2->已发货；3->已完成；4->已关闭；5->无效订单。';


```



### oms_order_return_apply  订单退货申请表

```mysql
CREATE TABLE `oms_order_return_apply` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) DEFAULT NULL COMMENT '订单id',
  `company_address_id` bigint(20) DEFAULT NULL COMMENT '收货地址表id',
  `product_id` bigint(20) DEFAULT NULL COMMENT '退货商品id',
  `order_sn` varchar(64) DEFAULT NULL COMMENT '订单编号',
  `create_time` datetime DEFAULT NULL COMMENT '申请时间',
  `member_username` varchar(64) DEFAULT NULL COMMENT '会员用户名',
  `return_amount` decimal(10,2) DEFAULT NULL COMMENT '退款金额',
  `return_name` varchar(100) DEFAULT NULL COMMENT '退货人姓名',
  `return_phone` varchar(100) DEFAULT NULL COMMENT '退货人电话',
  `status` int(1) DEFAULT NULL COMMENT '申请状态：0->待处理；1->退货中；2->已完成；3->已拒绝',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `product_pic` varchar(500) DEFAULT NULL COMMENT '商品图片',
  `product_name` varchar(200) DEFAULT NULL COMMENT '商品名称',
  `product_brand` varchar(200) DEFAULT NULL COMMENT '商品品牌',
  `product_attr` varchar(500) DEFAULT NULL COMMENT '商品销售属性：颜色：红色；尺码：xl;',
  `product_count` int(11) DEFAULT NULL COMMENT '退货数量',
  `product_price` decimal(10,2) DEFAULT NULL COMMENT '商品单价',
  `product_real_price` decimal(10,2) DEFAULT NULL COMMENT '商品实际支付单价',
  `reason` varchar(200) DEFAULT NULL COMMENT '原因',
  `description` varchar(500) DEFAULT NULL COMMENT '描述',
  `proof_pics` varchar(1000) DEFAULT NULL COMMENT '凭证图片，以逗号隔开',
  `handle_note` varchar(500) DEFAULT NULL COMMENT '处理备注',
  `handle_man` varchar(100) DEFAULT NULL COMMENT '处理人员',
  `receive_man` varchar(100) DEFAULT NULL COMMENT '收货人',
  `receive_time` datetime DEFAULT NULL COMMENT '收货时间',
  `receive_note` varchar(500) DEFAULT NULL COMMENT '收货备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='订单退货申请表,主要用于存储会员退货申请信息，需要注意的是订单退货申请表的四种状态：0->待处理；1->退货中；2->已完成；3->已拒绝。';


```

###  oms_order_item订单商品列表表

```mysql
CREATE TABLE `oms_order_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) DEFAULT NULL COMMENT '订单id',
  `order_sn` varchar(64) DEFAULT NULL COMMENT '订单编号',
  `product_id` bigint(20) DEFAULT NULL COMMENT '商品id',
  `product_pic` varchar(500) DEFAULT NULL COMMENT '商品图片',
  `product_name` varchar(200) DEFAULT NULL COMMENT '商品名称',
  `product_brand` varchar(200) DEFAULT NULL COMMENT '商品品牌',
  `product_sn` varchar(64) DEFAULT NULL COMMENT '商品条码',
  `product_price` decimal(10,2) DEFAULT NULL COMMENT '销售价格',
  `product_quantity` int(11) DEFAULT NULL COMMENT '购买数量',
  `product_sku_id` bigint(20) DEFAULT NULL COMMENT '商品sku编号',
  `product_sku_code` varchar(50) DEFAULT NULL COMMENT '商品sku条码',
  `product_category_id` bigint(20) DEFAULT NULL COMMENT '商品分类id',
  `sp1` varchar(100) DEFAULT NULL COMMENT '商品的销售属性1',
  `sp2` varchar(100) DEFAULT NULL COMMENT '商品的销售属性2',
  `sp3` varchar(100) DEFAULT NULL COMMENT '商品的销售属性3',
  `promotion_name` varchar(200) DEFAULT NULL COMMENT '商品促销名称',
  `promotion_amount` decimal(10,2) DEFAULT NULL COMMENT '商品促销分解金额',
  `coupon_amount` decimal(10,2) DEFAULT NULL COMMENT '优惠券优惠分解金额',
  `integration_amount` decimal(10,2) DEFAULT NULL COMMENT '积分优惠分解金额',
  `real_amount` decimal(10,2) DEFAULT NULL COMMENT '该商品经过优惠后的分解金额',
  `gift_integration` int(11) NOT NULL DEFAULT '0' COMMENT '商品赠送积分',
  `gift_growth` int(11) NOT NULL DEFAULT '0' COMMENT '商品赠送成长值',
  `product_attr` varchar(500) DEFAULT NULL COMMENT '商品销售属性:[{"key":"颜色","value":"颜色"},{"key":"容量","value":"4G"}]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='订单中包含的商品信息，一个订单中会有多个订单商品信息。';


```

### oms_order_operate_history订单操作记录表

```mysql
CREATE TABLE `oms_order_operate_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) DEFAULT NULL COMMENT '订单id',
  `operate_man` varchar(100) DEFAULT NULL COMMENT '操作人：用户；系统；后台管理员',
  `create_time` datetime DEFAULT NULL COMMENT '操作时间',
  `order_status` int(1) DEFAULT NULL COMMENT '订单状态：0->待付款；1->待发货；2->已发货；3->已完成；4->已关闭；5->无效订单',
  `note` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='订单操作记录表,当订单状态发生改变时，用于记录订单的操作信息。';
```

## 相关ER图

![image-20201214211206679](https://gitee.com/claa/tuci/raw/master/img/image-20201214211206679.png)



![image-20201214214503538](https://gitee.com/claa/tuci/raw/master/img/image-20201214214503538.png)



​                                                 ![image-20201214215232927](https://gitee.com/claa/tuci/raw/master/img/image-20201214215232927.png)

## 参考文章



[entity、bo、vo、po、dto、pojo](https://www.jianshu.com/p/b934b0d72602)

[Lombok的基本使用](https://www.jianshu.com/p/2543c71a8e45)

[swagger的基本用法](https://blog.csdn.net/andywei147/article/details/108372420)

[Intellij IDEA中的Terminal工具不识别node/npm等命令](https://blog.csdn.net/lz1989519821/article/details/89380071)

[Cannot download "https://github.com/sass/node-sass/releases/download...问题](https://blog.csdn.net/QQ736238785/article/details/110847486)  

[vue做前后端分离两种方式实现数据交互，路径跳转](https://blog.csdn.net/sunrj_niu/article/details/106888224)

[Mybatis generator工具介绍](https://www.cnblogs.com/zhouguanglin/p/11239583.html)





##  商品相关的业务学习

先看看功能菜单的效果图：



![image-20201226110552211](https://gitee.com/claa/tuci/raw/master/img/image-20201226110552211.png)

### 商品列表功能

#### 效果图

![image-20201218213619986](https://gitee.com/claa/tuci/raw/master/img/image-20201218213619986.png)

#### 商品分类这个搜索框





![image-20201218213826841](https://gitee.com/claa/tuci/raw/master/img/image-20201218213826841.png)

elementUI 官网是静态的数据，下面是官网的效果图，[Cascader级联选择器](https://element.eleme.cn/#/zh-CN/component/cascader)

![sdd1](https://gitee.com/claa/tuci/raw/master/img/sdd1.gif)



接下来，我看看动态的数据如何实现：

#### 前台代码

```vue
<el-form-item label="商品分类：">
            <el-cascader
              clearable
              v-model="selectProductCateValue"
              :options="productCateOptions">
            </el-cascader>
</el-form-item>
```





```
 created() {
      this.getList();
      this.getBrandList();
      this.getProductCateList();
    },
    watch: {
      selectProductCateValue: function (newValue) {
        if (newValue != null && newValue.length == 2) {
          this.listQuery.productCategoryId = newValue[1];
        } else {
          this.listQuery.productCategoryId = null;
        }

      }
    },
```



```vue
getProductCateList() {
        fetchListWithChildren().then(response => {
          let list = response.data;
          this.productCateOptions = [];
          for (let i = 0; i < list.length; i++) {
            let children = [];
            if (list[i].children != null && list[i].children.length > 0) {
              for (let j = 0; j < list[i].children.length; j++) {
                children.push({label: list[i].children[j].name, value: list[i].children[j].id});
              }
            }
            this.productCateOptions.push({label: list[i].name, value: list[i].id, children: children});
          }
        });
      },
```

数据格式如下：

```json
 options: [{
          value: 'zhinan',
          label: '指南',
          children: [{
            value: 'shejiyuanze',
            label: '设计原则',
            children: [{
              value: 'yizhi',
              label: '一致'
            }, {
              value: 'fankui',
              label: '反馈'
            }, {
              value: 'xiaolv',
              label: '效率'
            }, {
              value: 'kekong',
              label: '可控'
            }]
          }]
```



```js
export function fetchListWithChildren() {
  return request({
    url:'/productCategory/list/withChildren',
    method:'get'
  })
}
```



#### 后台代码

#### PmsProductCategoryController

```java
@Controller
@Api(tags = "PmsProductCategoryController", description = "商品分类管理")
@RequestMapping("/productCategory")
public class PmsProductCategoryController { 
@ApiOperation("查询所有一级分类及子分类")
    @RequestMapping(value = "/list/withChildren", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<List<PmsProductCategoryWithChildrenItem>> listWithChildren() {
        List<PmsProductCategoryWithChildrenItem> list = productCategoryService.listWithChildren();
        return CommonResult.success(list);
    }
}
```



#### PmsProductCategoryService

```java
public interface PmsProductCategoryService {
     /**
     * 以层级形式获取商品分类
     */
    List<PmsProductCategoryWithChildrenItem> listWithChildren();
}

```



#### PmsProductCategoryServiceImpl

```java
public class PmsProductCategoryServiceImpl implements PmsProductCategoryService {
    @Override
    public List<PmsProductCategoryWithChildrenItem> listWithChildren() {
        return productCategoryDao.listWithChildren();
    }

}
```



#### PmsProductCategoryDao

```java
public interface PmsProductCategoryDao {
    /**
     * 获取商品分类及其子分类
     */
    List<PmsProductCategoryWithChildrenItem> listWithChildren();
}

```



#### PmsProductCategoryDao.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.macro.mall.dao.PmsProductCategoryDao">
    <resultMap id="listWithChildrenMap" type="com.macro.mall.dto.PmsProductCategoryWithChildrenItem"
               extends="com.macro.mall.mapper.PmsProductCategoryMapper.BaseResultMap">
        <collection property="children" resultMap="com.macro.mall.mapper.PmsProductCategoryMapper.BaseResultMap"
                    columnPrefix="child_"></collection>
    </resultMap>
    <select id="listWithChildren" resultMap="listWithChildrenMap">
        select
            c1.id,
            c1.name,
            c2.id   child_id,
            c2.name child_name
        from pms_product_category c1 left join pms_product_category c2 on c1.id = c2.parent_id
        where c1.parent_id = 0
    </select>
</mapper>
```



#### pms_product_category.sql

```sql
 select
            c1.id,
            c1.name,
            c2.id   child_id,
            c2.name child_name
        from pms_product_category c1 left join pms_product_category c2 on c1.id = c2.parent_id
        where c1.parent_id = 0;
+----+----------+----------+------------+
| id | name     | child_id | child_name |
+----+----------+----------+------------+
|  1 | 服装     |        7 | 外套       |
|  1 | 服装     |        8 | T恤        |
|  1 | 服装     |        9 | 休闲裤     |
|  1 | 服装     |       10 | 牛仔裤     |
|  1 | 服装     |       11 | 衬衫       |
|  1 | 服装     |       29 | 男鞋       |
|  2 | 手机数码 |       19 | 手机通讯   |
|  2 | 手机数码 |       30 | 手机配件   |
|  2 | 手机数码 |       31 | 摄影摄像   |
|  2 | 手机数码 |       32 | 影音娱乐   |
|  2 | 手机数码 |       33 | 数码配件   |
|  2 | 手机数码 |       34 | 智能设备   |
|  3 | 家用电器 |       35 | 电视       |
|  3 | 家用电器 |       36 | 空调       |
|  3 | 家用电器 |       37 | 洗衣机     |
|  3 | 家用电器 |       38 | 冰箱       |
|  3 | 家用电器 |       39 | 厨卫大电   |
|  3 | 家用电器 |       40 | 厨房小电   |
|  3 | 家用电器 |       41 | 生活电器   |
|  3 | 家用电器 |       42 | 个护健康   |
|  4 | 家具家装 |       43 | 厨房卫浴   |
|  4 | 家具家装 |       44 | 灯饰照明   |
|  4 | 家具家装 |       45 | 五金工具   |
|  4 | 家具家装 |       46 | 卧室家具   |
|  4 | 家具家装 |       47 | 客厅家具   |
|  5 | 汽车用品 |       48 | 全新整车   |
|  5 | 汽车用品 |       49 | 车载电器   |
|  5 | 汽车用品 |       50 | 维修保养   |
|  5 | 汽车用品 |       51 | 汽车装饰   |
+----+----------+----------+------------+
```



#### 数据列表中商品图片，标签，SKU 库存

![image-20201219075812195](https://gitee.com/claa/tuci/raw/master/img/image-20201219075812195.png)



#### 前台代码

```vue
<el-table-column label="商品图片" width="120" align="center">
          <template slot-scope="scope"><img style="height: 80px" :src="scope.row.pic"></template>
        </el-table-column>
        <el-table-column label="商品名称" align="center">
          <template slot-scope="scope">
            <p>{{scope.row.name}}</p>
            <p>品牌：{{scope.row.brandName}}</p>
          </template>
        </el-table-column>
        <el-table-column label="价格/货号" width="120" align="center">
          <template slot-scope="scope">
            <p>价格：￥{{scope.row.price}}</p>
            <p>货号：{{scope.row.productSn}}</p>
          </template>
        </el-table-column>
        <el-table-column label="标签" width="140" align="center">
          <template slot-scope="scope">
            <p>上架：
              <el-switch
                @change="handlePublishStatusChange(scope.$index, scope.row)"
                :active-value="1"
                :inactive-value="0"
                v-model="scope.row.publishStatus">
              </el-switch>
            </p>
            <p>新品：
              <el-switch
                @change="handleNewStatusChange(scope.$index, scope.row)"
                :active-value="1"
                :inactive-value="0"
                v-model="scope.row.newStatus">
              </el-switch>
            </p>
            <p>推荐：
              <el-switch
                @change="handleRecommendStatusChange(scope.$index, scope.row)"
                :active-value="1"
                :inactive-value="0"
                v-model="scope.row.recommandStatus">
              </el-switch>
            </p>
          </template>
        </el-table-column>
        <el-table-column label="排序" width="100" align="center">
          <template slot-scope="scope">{{scope.row.sort}}</template>
        </el-table-column>
        <el-table-column label="SKU库存" width="100" align="center">
          <template slot-scope="scope">
            <el-button type="primary" icon="el-icon-edit" @click="handleShowSkuEditDialog(scope.$index, scope.row)" circle></el-button>
          </template>
        </el-table-column>
```



```js
// 查询全部 
getList() {
        this.listLoading = true;
        fetchList(this.listQuery).then(response => {
          this.listLoading = false;
          this.list = response.data.list;
          this.total = response.data.total;
        });
      },

 // 标签中，上架状态的更新，支持单个和批量修改
 handlePublishStatusChange(index, row) {
        let ids = [];
        ids.push(row.id);
        this.updatePublishStatus(row.publishStatus, ids);
      },
  pdatePublishStatus(publishStatus, ids) {
        let params = new URLSearchParams();
        params.append('ids', ids);
        params.append('publishStatus', publishStatus);
        updatePublishStatus(params).then(response => {
          this.$message({
            message: '修改成功',
            type: 'success',
            duration: 1000
          });
        });
      },
       
   // SKU 弹窗，并查询信息       
   handleShowSkuEditDialog(index,row){
        this.editSkuInfo.dialogVisible=true;
        this.editSkuInfo.productId=row.id;
        this.editSkuInfo.productSn=row.productSn;
        this.editSkuInfo.productAttributeCategoryId = row.productAttributeCategoryId;
        this.editSkuInfo.keyword=null;
        fetchSkuStockList(row.id,{keyword:this.editSkuInfo.keyword}).then(response=>{
          this.editSkuInfo.stockList=response.data;
        });
        if(row.productAttributeCategoryId!=null){
          fetchProductAttrList(row.productAttributeCategoryId,{type:0}).then(response=>{
            this.editSkuInfo.productAttr=response.data.list;
          });
        }
      },
```

```js
export function fetchList(params) {
  return request({
    url:'/product/list',
    method:'get',
    params:params
  })
}


export function updatePublishStatus(params) {
  return request({
    url:'/product/update/publishStatus',
    method:'post',
    params:params
  })
}

export function fetchList(pid,params) {
  return request({
    url:'/sku/'+pid,
    method:'get',
    params:params
  })
}
```



**标签**这个功能对应的是Element 中 [Switch 开关](https://element.eleme.cn/#/zh-CN/component/switch),比单纯的按钮，好看多了，用户界面交互友好，还是蛮重要的（最起码，自己的产品可以卖的贵一些，是没有问题的）

![sdd2](https://gitee.com/claa/tuci/raw/master/img/sdd2.gif)



```vue
 <!--绑定v-model到一个Boolean类型的变量。可以使用active-color属性与inactive-color属性来设置开关的背景色。-->

<el-switch
  v-model="value"
  active-color="#13ce66"
  inactive-color="#ff4949">
</el-switch>

<script>
  export default {
    data() {
      return {
        value: true
      }
    }
  };
</script>
```





- SPU（Standard Product Unit ）:指的是标准商品单位，商品信息聚合的最小单位，是一组可复用、易检索的标准化信息的集合，该集合描述了一个商品的特性；
- SKU（Stock Keeping Unit）:库存量单位，是物理上不可分割的最小存货单元。

举个例子：比如说现在有个手机商品叫小米8，小米8有不同的属性，比如有它有黑色和蓝色的，有32G和64G版本的。此时`小米8`就是一个SPU，而`小米8黑色64G`就是一个SKU。  摘自[mall-learning](http://www.macrozheng.com/#/technology/product_sku?id=%e5%95%86%e5%93%81%e7%9a%84spu%e5%92%8csku)

![image-20201219085607985](https://gitee.com/claa/tuci/raw/master/img/image-20201219085607985.png)



#### 后台代码

#### PmsProductController

```java
public class PmsProductController {
@ApiOperation("查询商品")
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<CommonPage<PmsProduct>> getList(PmsProductQueryParam productQueryParam,
                                                        @RequestParam(value = "pageSize", defaultValue = "5") Integer pageSize,
                                                        @RequestParam(value = "pageNum", defaultValue = "1") Integer pageNum) {
        List<PmsProduct> productList = productService.list(productQueryParam, pageSize, pageNum);
        return CommonResult.success(CommonPage.restPage(productList));
    }
    
    
    @ApiOperation("批量上下架")
    @RequestMapping(value = "/update/publishStatus", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult updatePublishStatus(@RequestParam("ids") List<Long> ids,
                                            @RequestParam("publishStatus") Integer publishStatus) {
        int count = productService.updatePublishStatus(ids, publishStatus);
        if (count > 0) {
            return CommonResult.success(count);
        } else {
            return CommonResult.failed();
        }
    }
}
```



#### PmsProductService

```java
public interface PmsProductService {
/**
     * 分页查询商品
     */
    List<PmsProduct> list(PmsProductQueryParam productQueryParam, Integer pageSize, Integer pageNum);
}

/**
     * 批量修改商品上架状态
     */
    int updatePublishStatus(List<Long> ids, Integer publishStatus);

}
```



#### PmsProductService

```java

public class PmsProductServiceImpl implements PmsProductService {
@Override
    public List<PmsProduct> list(PmsProductQueryParam productQueryParam, Integer pageSize, Integer pageNum) {
        PageHelper.startPage(pageNum, pageSize);
        PmsProductExample productExample = new PmsProductExample();
        PmsProductExample.Criteria criteria = productExample.createCriteria();
        criteria.andDeleteStatusEqualTo(0);
        if (productQueryParam.getPublishStatus() != null) {
            criteria.andPublishStatusEqualTo(productQueryParam.getPublishStatus());
        }
        if (productQueryParam.getVerifyStatus() != null) {
            criteria.andVerifyStatusEqualTo(productQueryParam.getVerifyStatus());
        }
        if (!StringUtils.isEmpty(productQueryParam.getKeyword())) {
            criteria.andNameLike("%" + productQueryParam.getKeyword() + "%");
        }
        if (!StringUtils.isEmpty(productQueryParam.getProductSn())) {
            criteria.andProductSnEqualTo(productQueryParam.getProductSn());
        }
        if (productQueryParam.getBrandId() != null) {
            criteria.andBrandIdEqualTo(productQueryParam.getBrandId());
        }
        if (productQueryParam.getProductCategoryId() != null) {
            criteria.andProductCategoryIdEqualTo(productQueryParam.getProductCategoryId());
        }
        return productMapper.selectByExample(productExample);
    }
    
    
    
     @Override
    public int updatePublishStatus(List<Long> ids, Integer publishStatus) {
        PmsProduct record = new PmsProduct();
        record.setPublishStatus(publishStatus);
        PmsProductExample example = new PmsProductExample();
        example.createCriteria().andIdIn(ids);
        return productMapper.updateByExampleSelective(record, example);
    }
}
```



#### PmsSkuStockController

```java
@Api(tags = "PmsSkuStockController", description = "sku商品库存管理")
@RequestMapping("/sku")
public class PmsSkuStockController {
    @Autowired
    private PmsSkuStockService skuStockService;

    @ApiOperation("根据商品编号及编号模糊搜索sku库存")
    @RequestMapping(value = "/{pid}", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<List<PmsSkuStock>> getList(@PathVariable Long pid, @RequestParam(value = "keyword",required = false) String keyword) {
        List<PmsSkuStock> skuStockList = skuStockService.getList(pid, keyword);
        return CommonResult.success(skuStockList);
    }
}
```



#### PmsSkuStockService 

```java
public interface PmsSkuStockService {
    /**
     * 根据产品id和skuCode模糊搜索
     */
    List<PmsSkuStock> getList(Long pid, String keyword);
    
  

}

```



#### PmsSkuStockServiceImpl

```java
 public class PmsSkuStockServiceImpl implements PmsSkuStockService {
 @Override
    public List<PmsSkuStock> getList(Long pid, String keyword) {
        PmsSkuStockExample example = new PmsSkuStockExample();
        PmsSkuStockExample.Criteria criteria = example.createCriteria().andProductIdEqualTo(pid);
        if (!StringUtils.isEmpty(keyword)) {
            criteria.andSkuCodeLike("%" + keyword + "%");
        }
        return skuStockMapper.selectByExample(example);
    }
 }
```



## 添加商品功能

#### 效果图

##### 第一步 填写商品信息

![image-20201219093253548](https://gitee.com/claa/tuci/raw/master/img/image-20201219093253548.png)



##### 第二步 填写商品促销



![image-20201219095547509](https://gitee.com/claa/tuci/raw/master/img/image-20201219095547509.png)

##### 第三步 填写商品属性



​                   ![sdd202012190955](https://gitee.com/claa/tuci/raw/master/img/sdd202012190955.gif)



![image-20201219101727158](https://gitee.com/claa/tuci/raw/master/img/image-20201219101727158.png)

##### 第四步 选择商品关联

![image-20201219102137847](https://gitee.com/claa/tuci/raw/master/img/image-20201219102137847.png)

先整体来看看这个时间轴的效果，每一个节点是分别引入了一个组件，来看看代码：

### 前台代码



```vue
  <el-card class="form-container" shadow="never">
    <el-steps :active="active" finish-status="success" align-center>
      <el-step title="填写商品信息"></el-step>
      <el-step title="填写商品促销"></el-step>
      <el-step title="填写商品属性"></el-step>
      <el-step title="选择商品关联"></el-step>
    </el-steps>
    <product-info-detail
      v-show="showStatus[0]"
      v-model="productParam"
      :is-edit="isEdit"
      @nextStep="nextStep">
    </product-info-detail>
    <product-sale-detail
      v-show="showStatus[1]"
      v-model="productParam"
      :is-edit="isEdit"
      @nextStep="nextStep"
      @prevStep="prevStep">
    </product-sale-detail>
    <product-attr-detail
      v-show="showStatus[2]"
      v-model="productParam"
      :is-edit="isEdit"
      @nextStep="nextStep"
      @prevStep="prevStep">
    </product-attr-detail>
    <product-relation-detail
      v-show="showStatus[3]"
      v-model="productParam"
      :is-edit="isEdit"
      @prevStep="prevStep"
      @finishCommit="finishCommit">
    </product-relation-detail>
  </el-card>
```

```vue
export default {
    name: 'ProductDetail',
    components: {ProductInfoDetail, ProductSaleDetail, ProductAttrDetail, ProductRelationDetail},
    props: {
      isEdit: {
        type: Boolean,
        default: false
      }
    },
```



```vue
 import ProductInfoDetail from './ProductInfoDetail';
  import ProductSaleDetail from './ProductSaleDetail';
  import ProductAttrDetail from './ProductAttrDetail';
  import ProductRelationDetail from './ProductRelationDetail';
```

自定义标签分别为 <product-info-detail> , <product-sale-detail>,<product-attr-detail> <product-relation-detail>  ,允许大写，但是“-” 标签不能去掉，去掉后就无法正常显示，在网上没有找到具体的规则，有知道的同学，请留言。

![image-20201221220939827](https://gitee.com/claa/tuci/raw/master/img/image-20201221220939827.png)

这个四个节点的默认的数据信息都在ProductDetail 页面中，只是分别显示在四个页面里，最后保存，调用的方法也在这里。



```vue
<!--ProductDetail 页面-->

<product-relation-detail
  v-show="showStatus[3]"
  v-model="productParam"
  :is-edit="isEdit"
  @prevStep="prevStep"
  @finishCommit="finishCommit">
</product-relation-detail>
```

```vue
<!--ProductRelationDetail 页面-->
<el-form-item style="text-align: center">
        <el-button size="medium" @click="handlePrev">上一步，填写商品属性</el-button>
        <el-button type="primary" size="medium" @click="handleFinishCommit">完成，提交商品</el-button>
 </el-form-item>

handleFinishCommit(){
        this.$emit('finishCommit',this.isEdit);
}
      
```





![image-20201222214311873](https://gitee.com/claa/tuci/raw/master/img/image-20201222214311873.png)



```
<el-form-item label="关联专题：">
        <el-transfer
          style="display: inline-block"
          filterable
          :filter-method="filterMethod"
          filter-placeholder="请输入专题名称"
          v-model="selectSubject"
          :titles="subjectTitles"
          :data="subjectList">
        </el-transfer>
      </el-form-item>
      <el-form-item label="关联优选：">
        <el-transfer
          style="display: inline-block"
          filterable
          :filter-method="filterMethod"
          filter-placeholder="请输入优选名称"
          v-model="selectPrefrenceArea"
          :titles="prefrenceAreaTitles"
          :data="prefrenceAreaList">
        </el-transfer>
      </el-form-item>
```

### 后台代码

### PmsProductController

```java
@Controller
@Api(tags = "PmsProductController", description = "商品管理")
@RequestMapping("/product")
public class PmsProductController {
    @Autowired
    private PmsProductService productService;

    @ApiOperation("创建商品")
    @RequestMapping(value = "/create", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult create(@RequestBody PmsProductParam productParam, BindingResult bindingResult) {
        int count = productService.create(productParam);
        if (count > 0) {
            return CommonResult.success(count);
        } else {
            return CommonResult.failed();
        }
    }

    @ApiOperation("根据商品id获取商品编辑信息")
    @RequestMapping(value = "/updateInfo/{id}", method = RequestMethod.GET)
    @ResponseBody
    public CommonResult<PmsProductResult> getUpdateInfo(@PathVariable Long id) {
        PmsProductResult productResult = productService.getUpdateInfo(id);
        return CommonResult.success(productResult);
    }

    @ApiOperation("更新商品")
    @RequestMapping(value = "/update/{id}", method = RequestMethod.POST)
    @ResponseBody
    public CommonResult update(@PathVariable Long id, @RequestBody PmsProductParam productParam, BindingResult bindingResult) {
        int count = productService.update(id, productParam);
        if (count > 0) {
            return CommonResult.success(count);
        } else {
            return CommonResult.failed();
        }
    }

```



### PmsProductService

```java
public interface PmsProductService {
    /**
     * 创建商品
     */
    @Transactional(isolation = Isolation.DEFAULT,propagation = Propagation.REQUIRED)
    int create(PmsProductParam productParam);

    /**
     * 根据商品编号获取更新信息
     */
    PmsProductResult getUpdateInfo(Long id);

    /**
     * 更新商品
     */
    @Transactional
    int update(Long id, PmsProductParam productParam);
}
```

### PmsProductServiceImpl

```java
@Override
    public int create(PmsProductParam productParam) {
        int count;
        //创建商品
        PmsProduct product = productParam;
        product.setId(null);
        productMapper.insertSelective(product);
        //根据促销类型设置价格：会员价格、阶梯价格、满减价格
        Long productId = product.getId();
        //会员价格
        relateAndInsertList(memberPriceDao, productParam.getMemberPriceList(), productId);
        //阶梯价格
        relateAndInsertList(productLadderDao, productParam.getProductLadderList(), productId);
        //满减价格
        relateAndInsertList(productFullReductionDao, productParam.getProductFullReductionList(), productId);
        //处理sku的编码
        handleSkuStockCode(productParam.getSkuStockList(),productId);
        //添加sku库存信息
        relateAndInsertList(skuStockDao, productParam.getSkuStockList(), productId);
        //添加商品参数,添加自定义商品规格
        relateAndInsertList(productAttributeValueDao, productParam.getProductAttributeValueList(), productId);
        //关联专题
        relateAndInsertList(subjectProductRelationDao, productParam.getSubjectProductRelationList(), productId);
        //关联优选
        relateAndInsertList(prefrenceAreaProductRelationDao, productParam.getPrefrenceAreaProductRelationList(), productId);
        count = 1;
        return count;
    }


 @Override
    public int update(Long id, PmsProductParam productParam) {
        int count;
        //更新商品信息
        PmsProduct product = productParam;
        product.setId(id);
        productMapper.updateByPrimaryKeySelective(product);
        //会员价格
        PmsMemberPriceExample pmsMemberPriceExample = new PmsMemberPriceExample();
        pmsMemberPriceExample.createCriteria().andProductIdEqualTo(id);
        memberPriceMapper.deleteByExample(pmsMemberPriceExample);
        relateAndInsertList(memberPriceDao, productParam.getMemberPriceList(), id);
        //阶梯价格
        PmsProductLadderExample ladderExample = new PmsProductLadderExample();
        ladderExample.createCriteria().andProductIdEqualTo(id);
        productLadderMapper.deleteByExample(ladderExample);
        relateAndInsertList(productLadderDao, productParam.getProductLadderList(), id);
        //满减价格
        PmsProductFullReductionExample fullReductionExample = new PmsProductFullReductionExample();
        fullReductionExample.createCriteria().andProductIdEqualTo(id);
        productFullReductionMapper.deleteByExample(fullReductionExample);
        relateAndInsertList(productFullReductionDao, productParam.getProductFullReductionList(), id);
        //修改sku库存信息
        handleUpdateSkuStockList(id, productParam);
        //修改商品参数,添加自定义商品规格
        PmsProductAttributeValueExample productAttributeValueExample = new PmsProductAttributeValueExample();
        productAttributeValueExample.createCriteria().andProductIdEqualTo(id);
        productAttributeValueMapper.deleteByExample(productAttributeValueExample);
        relateAndInsertList(productAttributeValueDao, productParam.getProductAttributeValueList(), id);
        //关联专题
        CmsSubjectProductRelationExample subjectProductRelationExample = new CmsSubjectProductRelationExample();
        subjectProductRelationExample.createCriteria().andProductIdEqualTo(id);
        subjectProductRelationMapper.deleteByExample(subjectProductRelationExample);
        relateAndInsertList(subjectProductRelationDao, productParam.getSubjectProductRelationList(), id);
        //关联优选
        CmsPrefrenceAreaProductRelationExample prefrenceAreaExample = new CmsPrefrenceAreaProductRelationExample();
        prefrenceAreaExample.createCriteria().andProductIdEqualTo(id);
        prefrenceAreaProductRelationMapper.deleteByExample(prefrenceAreaExample);
        relateAndInsertList(prefrenceAreaProductRelationDao, productParam.getPrefrenceAreaProductRelationList(), id);
        count = 1;
        return count;
    }




/**
     * 建立和插入关系表操作
     *
     * @param dao       可以操作的dao
     * @param dataList  要插入的数据
     * @param productId 建立关系的id
     */
    private void relateAndInsertList(Object dao, List dataList, Long productId) {
        try {
            if (CollectionUtils.isEmpty(dataList)) return;
            for (Object item : dataList) {
                Method setId = item.getClass().getMethod("setId", Long.class);
                setId.invoke(item, (Long) null);
                Method setProductId = item.getClass().getMethod("setProductId", Long.class);
                setProductId.invoke(item, productId);
            }
            Method insertList = dao.getClass().getMethod("insertList", List.class);
            insertList.invoke(dao, dataList);
        } catch (Exception e) {
            LOGGER.warn("创建产品出错:{}", e.getMessage());
            throw new RuntimeException(e.getMessage());
        }
    }
```



### PmsProductParam

```java
@Data
@EqualsAndHashCode(callSuper = false)
public class PmsProductParam extends PmsProduct{
    @ApiModelProperty("商品阶梯价格设置")
    private List<PmsProductLadder> productLadderList;
    @ApiModelProperty("商品满减价格设置")
    private List<PmsProductFullReduction> productFullReductionList;
    @ApiModelProperty("商品会员价格设置")
    private List<PmsMemberPrice> memberPriceList;
    @ApiModelProperty("商品的sku库存信息")
    private List<PmsSkuStock> skuStockList;
    @ApiModelProperty("商品参数及自定义规格属性")
    private List<PmsProductAttributeValue> productAttributeValueList;
    @ApiModelProperty("专题和商品关系")
    private List<CmsSubjectProductRelation> subjectProductRelationList;
    @ApiModelProperty("优选专区和商品的关系")
    private List<CmsPrefrenceAreaProductRelation> prefrenceAreaProductRelationList;
}
```



## 商品分类、商品类型、品牌管理功能

这三个功能比较简单，会简单的表结构列一下。

#### 品牌

```sql
CREATE TABLE `pms_brand` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `first_letter` varchar(8) DEFAULT NULL COMMENT '首字母',
  `sort` int(11) DEFAULT NULL,
  `factory_status` int(1) DEFAULT NULL COMMENT '是否为品牌制造商：0->不是；1->是',
  `show_status` int(1) DEFAULT NULL,
  `product_count` int(11) DEFAULT NULL COMMENT '产品数量',
  `product_comment_count` int(11) DEFAULT NULL COMMENT '产品评论数量',
  `logo` varchar(255) DEFAULT NULL COMMENT '品牌logo',
  `big_pic` varchar(255) DEFAULT NULL COMMENT '专区大图',
  `brand_story` text COMMENT '品牌故事',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8 COMMENT='品牌表';
```



![image-20201219094848808](https://gitee.com/claa/tuci/raw/master/img/image-20201219094848808.png)



![image-20201219095126294](https://gitee.com/claa/tuci/raw/master/img/image-20201219095126294.png)

####  商品分类

```sql
CREATE TABLE `pms_product_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) DEFAULT NULL COMMENT '上机分类的编号：0表示一级分类',
  `name` varchar(64) DEFAULT NULL,
  `level` int(1) DEFAULT NULL COMMENT '分类级别：0->1级；1->2级',
  `product_count` int(11) DEFAULT NULL,
  `product_unit` varchar(64) DEFAULT NULL,
  `nav_status` int(1) DEFAULT NULL COMMENT '是否显示在导航栏：0->不显示；1->显示',
  `show_status` int(1) DEFAULT NULL COMMENT '显示状态：0->不显示；1->显示',
  `sort` int(11) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL COMMENT '图标',
  `keywords` varchar(255) DEFAULT NULL,
  `description` text COMMENT '描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8 COMMENT='产品分类';
```

![image-20201219094953287](https://gitee.com/claa/tuci/raw/master/img/image-20201219094953287.png)



![image-20201219095223575](https://gitee.com/claa/tuci/raw/master/img/image-20201219095223575.png)



####  商品类型

```sql
CREATE TABLE `pms_product_attribute_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `attribute_count` int(11) DEFAULT '0' COMMENT '属性数量',
  `param_count` int(11) DEFAULT '0' COMMENT '参数数量',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COMMENT='产品属性分类表';
```

![image-20201219095054297](https://gitee.com/claa/tuci/raw/master/img/image-20201219095054297.png)



![image-20201219095247253](https://gitee.com/claa/tuci/raw/master/img/image-20201219095247253.png)



## 营销相关的业务学习

## 权限相关的业务学习



