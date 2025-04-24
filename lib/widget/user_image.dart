import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget{
  UserImage({super.key,required this.onpickedImage});


  final void Function(File PickedImage)onpickedImage;
  @override
  State<UserImage> createState() {
 return _UserImageState();
  }

}
class _UserImageState extends State<UserImage>{
  File ?_PickedImageFile;
  void pickImage()async{
final pickImage=await ImagePicker().pickImage(source: ImageSource.camera,
    imageQuality: 50,
  maxHeight: 150,
);
if(pickImage==null){
  return;
}
setState(() {
  _PickedImageFile=File(pickImage.path);
});
widget.onpickedImage(_PickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(onTap: pickImage,
        child: CircleAvatar(radius: 40,child: Icon(Icons.person,color: Colors.white,size: 50,),
          backgroundColor: Colors.grey,
          foregroundImage: _PickedImageFile!=null?
          FileImage(_PickedImageFile!):null,
        ),
      ),

    ],);
  }
}
