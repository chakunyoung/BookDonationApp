package com.bookdone.history.infra.database;

import com.bookdone.history.infra.entity.HistoryEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface JpaHistoryRepository extends JpaRepository<HistoryEntity, Long> {

    Optional<HistoryEntity> findById(Long id);

    Optional<HistoryEntity> findByDonationIdAndMemberId(Long donationId, Long memberId);
}