package com.bookdone.book.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberResponse {
	private Long id;
	private String oauthId;
	private String nickname;
	private String address;
	private Integer point;
	private String email;
	private String image;
}
