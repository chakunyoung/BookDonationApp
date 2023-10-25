package com.bookdone.donation.dto.request;

import com.bookdone.donation.domain.Donation;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class DonationAddRequest {

    private Long isbn;
    private Long memberId;
    private Integer address;
    private String content;
    private boolean canDelivery;
    private List<MultipartFile> images;

    public Donation toDomain() {
        return Donation.createDonation(this);
    }
}