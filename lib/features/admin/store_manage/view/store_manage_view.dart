import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/admin/store_manage/controller/store_manage_controller.dart';
import 'package:online_groceries_app/features/admin/store_manage/models/store_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class StoreManageView extends StatelessWidget {
   StoreManageView({super.key});
  final StoreController controller = Get.put(StoreController());

  @override
  Widget build(BuildContext context) {

    return  Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stores",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(
                  width: 150.w,
                  child: CommonButton(
                    title: "Add Store",
                    onTap: () => _openStoreDialog(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Store List
            Expanded(
              child: Obx(() {
                if (controller.stores.isEmpty) {
                  return const Center(child: Text("No stores found"));
                }

                return ListView.separated(
                  itemCount: controller.stores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final store = controller.stores[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.store, color: AppColors.primary),
                        ),
                        title: Text(
                          store.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        subtitle: Text(
                          store.address,
                          style: TextStyle(
                            color: AppColors.grayTextColor,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: AppColors.primary,
                              onPressed: () =>
                                  _openStoreDialog(context, store: store),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _deleteDialog(context, store.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

          ],
        ),
      );
  }

  /// Add / Update Store Dialog
   void _openStoreDialog(
       BuildContext context, {
         StoreModel? store,
       }) {
     final nameController = TextEditingController(text: store?.name ?? '');
     final addressController = TextEditingController(text: store?.address ?? '');
     final controller = Get.find<StoreController>();

     final isEdit = store != null;


     showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.whiteColor,
        title: Text(
          isEdit ? "Update Store" : "Add Store",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextField(label: "Store Name", controller: nameController,hint: 'Enter store name',),
            SizedBox(height: 12.h),
            CommonTextField(label: "Store Address", controller: addressController,hint: 'Enter store address',),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text(
              "Cancel",
              style: TextStyle(color: Colors.black,fontSize: 17.sp),
            ),
          ),

          SizedBox(
            width: 120.w,
            child:CommonButton(
              title: isEdit ? "Update" : "Add",
              onTap: () async {
                if (isEdit) {
                  await controller.updateStore(
                    id: store!.id,
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                  );
                } else {
                  await controller.addStore(
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                  );
                }
                Get.back();
              },
            ),
          )

        ],
      ),
    );
  }

  /// Delete Confirmation Dialog
   void _deleteDialog(BuildContext context, String storeId) {
     final controller = Get.find<StoreController>();

     showDialog(
       context: context,
       builder: (_) => AlertDialog(
         title: const Text("Delete Store"),
         content: const Text("Are you sure you want to delete this store?"),
         actions: [
           TextButton(
             onPressed: () => Get.back(),
             child: const Text("Cancel"),
           ),
           CommonButton(
             title: "Delete",
             onTap: () async {
               await controller.deleteStore(storeId);
               Get.back();
             },
           ),
         ],
       ),
     );
   }

}

