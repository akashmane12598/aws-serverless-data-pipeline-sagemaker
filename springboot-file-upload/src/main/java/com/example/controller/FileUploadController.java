package com.example.controller;

import com.example.dto.PresignedUrlRequest;

import com.example.dto.PresignedUrlResponse;

import com.example.service.S3PresignedUrlService;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.*;

@RestController

@RequestMapping("/backend/files")

public class FileUploadController {

    private final S3PresignedUrlService s3PresignedUrlService;

    public FileUploadController(S3PresignedUrlService s3PresignedUrlService) {

        this.s3PresignedUrlService = s3PresignedUrlService;

    }

    @PostMapping("/presigned-url")

    public ResponseEntity<PresignedUrlResponse> generatePresignedUrl(

            @RequestBody PresignedUrlRequest request

    ) {

        PresignedUrlResponse response = s3PresignedUrlService.generateUploadUrl(

                request.getFileName(),

                request.getContentType()

        );

        return ResponseEntity.ok(response);

    }

    @GetMapping("/health")

    public ResponseEntity<String> health() {

        return ResponseEntity.ok("UP");

    }

}