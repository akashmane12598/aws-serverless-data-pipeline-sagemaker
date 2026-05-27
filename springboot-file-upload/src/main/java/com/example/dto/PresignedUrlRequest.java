package com.example.dto;

public class PresignedUrlRequest {

    private String fileName;

    private String contentType;

    public String getFileName() {

        return fileName;

    }

    public void setFileName(String fileName) {

        this.fileName = fileName;

    }

    public String getContentType() {

        return contentType;

    }

    public void setContentType(String contentType) {

        this.contentType = contentType;

    }

}