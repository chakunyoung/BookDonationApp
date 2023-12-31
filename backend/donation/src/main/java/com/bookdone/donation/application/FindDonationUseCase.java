package com.bookdone.donation.application;

import com.bookdone.client.api.BookClient;
import com.bookdone.client.api.MemberClient;
import com.bookdone.client.dto.BookResponse;
import com.bookdone.donation.application.repository.DonationImageRepository;
import com.bookdone.donation.application.repository.DonationRepository;
import com.bookdone.donation.domain.Donation;
import com.bookdone.donation.dto.response.*;
import com.bookdone.history.application.repository.HistoryRepository;
import com.bookdone.history.domain.History;
import com.bookdone.history.dto.response.HistoryResponse;
import com.bookdone.util.ResponseUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import feign.FeignException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class FindDonationUseCase {

    private final DonationRepository donationRepository;
    private final HistoryRepository historyRepository;
    private final DonationImageRepository donationImageRepository;
    private final MemberClient memberClient;
    private final ResponseUtil responseUtil;
    private final BookClient bookClient;

    public List<DonationListResponse> findDonationList(String isbn, String address) throws JsonProcessingException {
        List<Donation> donationList = null;

        if(address.substring(2, 4).equals("00"))
            donationList = donationRepository.findAllAddressByIsbnAndAddress(isbn, address);
        else
            donationList = donationRepository.findAllByIsbnAndAddress(isbn, address);

        if (donationList.isEmpty()) return new ArrayList<DonationListResponse>();

        List<Long> memberIdList = donationList.stream()
                .map(donation -> donation.getMemberId())
                .collect(Collectors.toList());

        Map<String, String> nicknameMap = null;

        try {
            nicknameMap = responseUtil.extractDataFromResponse(memberClient.getNicknameList(memberIdList), HashMap.class);
        } catch (FeignException.NotFound e) {
            throw e;
        }

        List<DonationListResponse> donationListResponseList = createDonationListResponse(
                donationList, nicknameMap);

        return donationListResponseList;
    }

    public List<DonationListResponse> createDonationListResponse(List<Donation> donationList, Map<String, String> nicknameMap) {
        List<DonationListResponse> donationListResponseList = new ArrayList<>();

        for (Donation donation : donationList) {
            String nickname = nicknameMap.get(String.valueOf(donation.getMemberId()));

            DonationListResponse donationListResponse = DonationListResponse
                    .builder()
                    .id(donation.getId())
                    .nickname(nickname)
                    .historyCount(historyRepository.countAllByDonationId(donation.getId()))
                    .address(donation.getAddress())
                    .createdAt(donation.getCreatedAt())
                    .build();
            donationListResponseList.add(donationListResponse);
        }

        return donationListResponseList;
    }

    public DonationDetailsResponse findDonation(Long memberId, Long id) throws JsonProcessingException {
        Donation donation = donationRepository.findById(id);

        String nickname = null;

        try {
            nickname = responseUtil.extractDataFromResponse(memberClient.getNickname(donation.getMemberId()),String.class);
        } catch (FeignException.NotFound e) {
            throw e;
        }

        List<String> imageUrlList = donationImageRepository.findImageUrlList(id, memberId);

        List<History> historyList = historyRepository.findAllByDonationId(id);
        List<Long> memberIdList = historyList.stream()
                .map(history -> history.getMemberId()).collect(Collectors.toList());

        Map<String, String> nicknameMap = null;
        try {
            nicknameMap = responseUtil.extractDataFromResponse(memberClient.getNicknameList(memberIdList), Map.class);
        } catch (FeignException.NotFound e) {
            throw e;
        }

        return createDonationResponse(memberId,donation, imageUrlList, nicknameMap, historyList, nickname);
    }

    public DonationDetailsResponse createDonationResponse(
        long memberId, Donation donation,
            List<String> imageUrlList,
            Map<String, String> nicknameMap,
            List<History> historyList,
            String nickname) throws JsonProcessingException {

        ObjectMapper objectMapper = new ObjectMapper();

        BookResponse bookResponse = responseUtil.extractDataFromResponse(
                bookClient.getBookInfo(memberId, donation.getIsbn()), BookResponse.class);

        List<HistoryResponse> historyResponseList = historyList.stream().map(history -> HistoryResponse.builder()
                .content(history.getContent())
                .nickname(nicknameMap.get(String.valueOf(history.getMemberId())))
                .createdAt(history.getCreatedAt())
                .titleUrl(bookResponse.getTitleUrl())
                .title(bookResponse.getTitle())
                .build()).collect(Collectors.toList());

        return DonationDetailsResponse.builder()
                .id(donation.getId())
                .isbn(donation.getIsbn())
                .nickname(nickname)
                .address(donation.getAddress())
                .content(donation.getContent())
                .canDelivery(donation.isCanDelivery())
                .historyResponseList(historyResponseList)
                .imageUrlList(imageUrlList)
                .build();
    }

    public List<DonationMyPageResponse> findDonationListByMember(Long memberId) {
        List<Donation> donationList = donationRepository.findAllByMemberId(memberId);

        if(donationList.isEmpty()) return new ArrayList<DonationMyPageResponse>();

        Map<String, BookResponse> bookResponseMap = null;

        List<String> isbnList = donationList.stream().map(donation -> donation.getIsbn())
                .collect(Collectors.toList());
        try {
            bookResponseMap = responseUtil.extractDataFromResponse(bookClient.getBookInfoList(memberId,isbnList), Map.class);
        } catch (FeignException.NotFound e) {
            throw e;
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        return createDonationMyPageResponse(memberId,donationList, bookResponseMap);
    }

    public List<DonationMyPageResponse> createDonationMyPageResponse(
        Long memberId, List<Donation> donationList, Map<String, BookResponse> bookResponseMap) {
        List<DonationMyPageResponse> donationMyPageResponseList = donationList.stream().map(donation -> {

            List<History> historyList = historyRepository.findAllByDonationId(donation.getId());
            List<Long> memberIdList = historyList.stream().map(history -> history.getMemberId())
                    .collect(Collectors.toList());

            List<HistoryResponse> historyResponseList = null;

            try {
                Map<String, String> nicknameMap = responseUtil.extractDataFromResponse
                        (memberClient.getNicknameList(memberIdList), Map.class);
                BookResponse bookResponse = responseUtil.extractDataFromResponse(
                        bookClient.getBookInfo(memberId,donation.getIsbn()), BookResponse.class);
                historyResponseList = historyList.stream().map(history -> HistoryResponse.builder()
                        .content(history.getContent())
                        .nickname(nicknameMap.get(String.valueOf(history.getMemberId())))
                        .createdAt(history.getCreatedAt())
                        .title(bookResponse.getTitle())
                        .titleUrl(bookResponse.getTitleUrl())
                        .build()).collect(Collectors.toList());
            } catch (FeignException.NotFound e) {
                throw e;
            } catch (JsonProcessingException e) {
                throw new RuntimeException(e);
            }

            History lastHistory = historyRepository.findLastHistoryByDonationId(donation.getId());
            ObjectMapper objectMapper = new ObjectMapper();
            BookResponse bookResponse = objectMapper.convertValue(
                    bookResponseMap.get(donation.getIsbn()), BookResponse.class);

            return DonationMyPageResponse.builder()
                    .donationStatus(donation.getStatus())
                    .id(donation.getId())
                    .title(bookResponse.getTitle())
                    .titleUrl(bookResponse.getTitleUrl())
                    .historyResponseList(historyResponseList)
                    .isbn(bookResponse.getIsbn())
                    .donatedAt(lastHistory == null ? donation.getCreatedAt() : lastHistory.getDonatedAt())
                    .build();
        }).collect(Collectors.toList());

        return donationMyPageResponseList;
    }

    public List<DonationCountResponse> countDonationCount(String isbn, String address) {
        return donationRepository.countAllByIsbnAndAddress(isbn, address);
    }

    public List<DonationListNoHistoryResponse> findDonationListByMemberAndUnWritten(Long memberId) {
        List<Donation> donationList = donationRepository.findAllByMemberId(memberId);

        Map<Long, Donation> donationMap = donationList
                .stream().collect(Collectors.toMap(Donation::getId, donation -> donation));

        List<History> historyList = historyRepository.findAllUnwrittenByMemberId(memberId);

        List<DonationListNoHistoryResponse> donationListNoHistoryResponseList = historyList.stream()
                .map(history -> {
                    Donation donation = donationMap.get(history.getDonationId());
                    BookResponse bookResponse = null;
                    try {
                        bookResponse = responseUtil.extractDataFromResponse(
                                bookClient.getBookInfo(memberId, donation.getIsbn()), BookResponse.class);
                    } catch (JsonProcessingException e) {
                        throw new RuntimeException(e);
                    }
                    return DonationListNoHistoryResponse.builder()
                            .title(bookResponse.getTitle())
                            .titleUrl(bookResponse.getTitleUrl())
                            .id(donation.getId())
                            .build();
                }).collect(Collectors.toList());

        return donationListNoHistoryResponseList;
    }

    public long findDonationMemberIdByDonationId(Long id) {
        Donation donation = donationRepository.findById(id);
        return donation.getMemberId();
    }
}
