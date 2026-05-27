package com.example.service;

import com.example.dto.PresignedUrlResponse;

import org.springframework.beans.factory.annotation.Value;

import org.springframework.stereotype.Service;

import software.amazon.awssdk.regions.Region;

import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import software.amazon.awssdk.services.s3.presigner.S3Presigner;

import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

import java.time.Duration;

import java.util.UUID;

@Service

public class S3PresignedUrlService {

    private final S3Presigner s3Presigner;

    private final String bucketName;

    public S3PresignedUrlService(

            @Value("${aws.region}") String awsRegion,

            @Value("${aws.s3.bucket-name}") String bucketName

    ) {

        this.s3Presigner = S3Presigner.builder()

                .region(Region.of(awsRegion))

                .build();

        this.bucketName = bucketName;

    }

    public PresignedUrlResponse generateUploadUrl(String fileName, String contentType) {

        String s3Key = "raw/" + UUID.randomUUID() + "-" + fileName;

        PutObjectRequest putObjectRequest = PutObjectRequest.builder()

                .bucket(bucketName)

                .key(s3Key)

                .contentType(contentType)

                .build();

        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()

                .signatureDuration(Duration.ofMinutes(10))

                .putObjectRequest(putObjectRequest)

                .build();

        String uploadUrl = s3Presigner.presignPutObject(presignRequest)

                .url()

                .toString();

        return new PresignedUrlResponse(uploadUrl, s3Key, bucketName);

    }

}
