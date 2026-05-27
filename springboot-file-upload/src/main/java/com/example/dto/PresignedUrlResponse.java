package com.example.dto;

public class PresignedUrlResponse {

    private String uploadUrl;

    private String s3Key;

    private String bucketName;

    public PresignedUrlResponse(String uploadUrl, String s3Key, String bucketName) {

        this.uploadUrl = uploadUrl;

        this.s3Key = s3Key;

        this.bucketName = bucketName;

    }

    public String getUploadUrl() {

        return uploadUrl;

    }

    public String getS3Key() {

        return s3Key;

    }

    public String getBucketName() {

        return bucketName;

    }

}
