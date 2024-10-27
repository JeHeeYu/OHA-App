import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:oha/models/upload/comment_read_model.dart';
import 'package:oha/models/upload/upload_report_model.dart';
import 'package:oha/repository/upload_repository.dart';
import '../models/upload/comment_write_model.dart';
import '../models/upload/upload_get_model.dart';
import '../models/upload/upload_like_model.dart';
import '../network/api_response.dart';

class UploadViewModel with ChangeNotifier {
  UploadRepository _uploadRepository = UploadRepository();

  List<String> _keywordList = [];
  String _mainUploadLocation = "";
  String _detailUploadLocation = "";

  List<String> get getKetwordList => _keywordList;
  String get getMainUploadLocation => _mainUploadLocation;
  String get getDetailUploadLocation => _detailUploadLocation;

  ApiResponse<UploadGetModel> uploadGetData = ApiResponse.loading();
  ApiResponse<UploadGetModel> popularUploadGetData = ApiResponse.loading();
  ApiResponse<UploadGetModel> myUploadGetData = ApiResponse.loading();
  ApiResponse<UploadGetModel> userUploadGetData = ApiResponse.loading();

  ApiResponse<UploadLikeModel> likeData = ApiResponse.loading();

  ApiResponse<CommentReadModel> commentReadData = ApiResponse.loading();
  ApiResponse<CommentReadModel> replyReadData = ApiResponse.loading();

  ApiResponse<CommentWriteModel> commentWriteData = ApiResponse.loading();

  ApiResponse<UploadReportModel> reportData = ApiResponse.loading();

  void setUploadKeywordList(String keyword) {
    _keywordList.add(keyword);
    notifyListeners();
  }

  void setMainUploadLocation(String location) {
    _mainUploadLocation = location;
    notifyListeners();
  }

  void setDetailUploadLocation(String location) {
    _detailUploadLocation = location;
    notifyListeners();
  }

  void setCommentRead(ApiResponse<CommentReadModel> response,
      {bool append = false}) {
    if (append &&
        response.status == Status.complete &&
        commentReadData.status == Status.complete) {
      commentReadData.data?.data.addAll(response.data?.data ?? []);
    } else {
      commentReadData = response;
    }
    notifyListeners();
  }

  void setReplyRead(ApiResponse<CommentReadModel> response) {
    replyReadData = response;
    notifyListeners();
  }

  void setCommentWrite(ApiResponse<CommentWriteModel> response) {
    commentWriteData = response;
    notifyListeners();
  }

  void _setUploadGetData(ApiResponse<UploadGetModel> response,
      {bool append = false}) {
    if (append &&
        response.status == Status.complete &&
        uploadGetData.status == Status.complete) {
      uploadGetData.data?.data.addAll(response.data?.data ?? []);
    } else {
      uploadGetData = response;
    }
    notifyListeners();
  }

  void _setPopularUploadGetData(ApiResponse<UploadGetModel> response,
      {bool append = false}) {
    if (append &&
        response.status == Status.complete &&
        popularUploadGetData.status == Status.complete) {
      popularUploadGetData.data?.data.addAll(response.data?.data ?? []);
    } else {
      popularUploadGetData = response;
    }
    notifyListeners();
  }

  void _setMyUploadGetData(ApiResponse<UploadGetModel> response) {
    myUploadGetData = response;
    notifyListeners();
  }

  void _setUserUploadGetData(ApiResponse<UploadGetModel> response) {
    userUploadGetData = response;
    notifyListeners();
  }

  void _setLikeData(ApiResponse<UploadLikeModel> response) {
    likeData = response;
    notifyListeners();
  }

  void clearUploadGetData() {
    uploadGetData = ApiResponse.complete(
        UploadGetModel(statusCode: 200, message: "", data: []));
    notifyListeners();
  }

  void clearPopularUploadGetData() {
    popularUploadGetData = ApiResponse.complete(
        UploadGetModel(statusCode: 200, message: "", data: []));
    notifyListeners();
  }

  void clearMyUploadGetData() {
    popularUploadGetData = ApiResponse.complete(
        UploadGetModel(statusCode: 200, message: "", data: []));
    notifyListeners();
  }

  void clearUserUploadGetData() {
    userUploadGetData = ApiResponse.complete(
        UploadGetModel(statusCode: 200, message: "", data: []));
    notifyListeners();
  }

  void postReport(ApiResponse<UploadReportModel> response) {
    reportData = response;
    notifyListeners();
  }

  Future<int> posting(
      Map<String, dynamic> data, Uint8List? thumbnailData, bool isVideo) async {
    final result =
        await _uploadRepository.posting(data, thumbnailData, isVideo);

    return result.statusCode;
  }

  Future<int> edit(
      Map<String, dynamic> data, Uint8List? thumbnailData, isVideo) async {
    final result = await _uploadRepository.edit(data, thumbnailData, isVideo);

    return result.statusCode;
  }

  Future<int> posts(Map<String, dynamic> queryParams,
      {bool append = false}) async {
    int statusCode = 400;
    await _uploadRepository.posts(queryParams).then((value) {
      _setUploadGetData(ApiResponse.complete(value), append: append);
      print("Jehee : ${value.data[0].regDtm}");
      statusCode = value.statusCode;
    }).onError((error, stackTrace) {
      _setUploadGetData(ApiResponse.error(error.toString()));
      statusCode = 400;
    });
    return statusCode;
  }

  Future<int> myPosts() async {
    int statusCode = 400;
    await _uploadRepository.myPosts().then((value) {
      _setMyUploadGetData(ApiResponse.complete(value));
      statusCode = value.statusCode;
    }).onError((error, stackTrace) {
      _setMyUploadGetData(ApiResponse.error(error.toString()));
      statusCode = 400;
    });
    return statusCode;
  }

  Future<int> popularPosts(Map<String, dynamic> queryParams,
      {bool append = false}) async {
    int statusCode = 400;
    await _uploadRepository.posts(queryParams).then((value) {
      _setPopularUploadGetData(ApiResponse.complete(value), append: append);
      statusCode = value.statusCode;
    }).onError((error, stackTrace) {
      _setPopularUploadGetData(ApiResponse.error(error.toString()));
      statusCode = 400;
    });
    return statusCode;
  }

  Future<int> userPosts(int userId) async {
    int statusCode = 400;
    await _uploadRepository.userPosts(userId).then((value) {
      _setUserUploadGetData(ApiResponse.complete(value));
      statusCode = value.statusCode;
    }).onError((error, stackTrace) {
      _setUserUploadGetData(ApiResponse.error(error.toString()));
      statusCode = 400;
    });
    return statusCode;
  }

  Future<int> like(Map<String, dynamic> data) async {
    final result = await _uploadRepository.like(data);

    if (result.statusCode == 200 || result.statusCode == 201) {
      int postId = data["postId"];
      bool isLike = data["type"] == "L";

      var post = uploadGetData.data?.data.firstWhere(
        (post) => post.postId == postId,
        orElse: () => UploadData.empty(),
      );

      var popularPost = popularUploadGetData.data?.data.firstWhere(
        (post) => post.postId == postId,
        orElse: () => UploadData.empty(),
      );

      if (post != null && post.postId != 0) {
        post.isLike = isLike;
        if (isLike) {
          post.likeCount += 1;
        } else {
          post.likeCount -= 1;
        }
      }

      if (popularPost != null && popularPost.postId != 0) {
        popularPost.isLike = isLike;
        if (isLike) {
          popularPost.likeCount += 1;
        } else {
          popularPost.likeCount -= 1;
        }
      }

      notifyListeners();
      _setLikeData(ApiResponse.complete(result));
    } else {
      _setLikeData(ApiResponse.error(result.toString()));
    }

    return result.statusCode;
  }

  Future<int> commentLike(Map<String, dynamic> data) async {
    final result = await _uploadRepository.commentLike(data);

    if (result.statusCode == 200 || result.statusCode == 201) {
      int commentId = data["commentId"];
      bool isLike = data["type"] == "L";

      CommentReadData? comment;

      if (commentReadData.data != null) {
        comment = commentReadData.data!.data.firstWhere(
          (comment) => comment.commentId == commentId,
          orElse: () => CommentReadData.empty(),
        );
      }

      if (comment == null && replyReadData.data != null) {
        comment = replyReadData.data!.data.firstWhere(
          (reply) => reply.commentId == commentId,
          orElse: () => CommentReadData.empty(),
        );
      }

      if (comment != null && comment.commentId != 0) {
        comment.isLike = isLike;
        if (isLike) {
          comment.likeCount += 1;
        } else {
          comment.likeCount -= 1;
        }
      }

      notifyListeners();
      _setLikeData(ApiResponse.complete(result));
    } else {
      _setLikeData(ApiResponse.error(result.toString()));
    }

    return result.statusCode;
  }

  Future<int> delete(String postId) async {
    final result = await _uploadRepository.delete(postId);

    if (result.statusCode == 200) {
      uploadGetData.data?.data
          .removeWhere((item) => item.postId == int.parse(postId));
      notifyListeners();
    }

    return result.statusCode;
  }

  Future<void> commentRead(Map<String, dynamic> queryParams,
      {bool append = false}) async {
    await _uploadRepository.commentRead(queryParams).then((value) {
      setCommentRead(ApiResponse.complete(value), append: append);
    }).onError((error, stackTrace) {
      setCommentRead(ApiResponse.error(error.toString()));
    });
  }

  Future<void> replyRead(Map<String, dynamic> queryParams) async {
    await _uploadRepository.commentRead(queryParams).then((value) {
      setReplyRead(ApiResponse.complete(value));
    }).onError((error, stackTrace) {
      setReplyRead(ApiResponse.error(error.toString()));
    });
  }

  Future<void> commentWrite(Map<String, dynamic> data) async {
    await _uploadRepository.commentWrite(data).then((value) {
      if (value.statusCode == 201) {
        commentReadData.data?.data.insert(0, value.data.toCommentReadData());
        notifyListeners();
      }
      setCommentWrite(ApiResponse.complete(value));
    }).onError((error, stackTrace) {
      setCommentWrite(ApiResponse.error(error.toString()));
    });
  }

  Future<void> report(Map<String, dynamic> data) async {
    await _uploadRepository.report(data).then((value) {
      postReport(ApiResponse.complete(value));
    }).onError((error, stackTrace) {
      postReport(ApiResponse.error(error.toString()));
    });
  }
}
