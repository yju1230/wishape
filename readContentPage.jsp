<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.6.1/font/bootstrap-icons.css">

<script type="text/javascript">
	
	var logined = false;
	var sessionNo = null;
	var boardNo = ${data.boardVo.board_no};
	
	
	function like() {
		
		if(logined == false){

			var result = confirm("로그인 하셔야 이용 가능합니다. 로그인 페이지로 이동하시겠습니까?");
			if(result){
				location.href = "../member/loginPage.do";				
			}
			return;
		}
		
		
		//AJAX API 사용....
		var xmlhttp = new XMLHttpRequest();
		
		xmlhttp.onreadystatechange = function(){
			if(xmlhttp.readyState==4 && xmlhttp.status==200){
				refreshLikeButton();
				refreshTotalLike();
			}
		};
		
		
		xmlhttp.open("get" , "./doLikeRest.do?board_no=${data.boardVo.board_no}"); 
		xmlhttp.send();
		
		
	}
	
	function refreshLikeButton(){
		
		if(logined == false){
			return;
		}
		
		//var aaa = null;
		//aaa.xxx = 10;
		
		
		var xmlhttp = new XMLHttpRequest();

		xmlhttp.onreadystatechange = function(){
			if(xmlhttp.readyState==4 && xmlhttp.status==200){
				var data = JSON.parse(xmlhttp.responseText);
				
				//렌더링..DOM 조작 : 엘리먼트 접근 , 생성 , 추가 , 삭제... 속성 컨트롤 , 스타일 컨트롤..
				var heartButton = document.getElementById("heartButton");
				
				if(data.myLikeCount > 0){
					heartButton.setAttribute("class" , "bi bi-heart-fill text-danger");
				}else{
					heartButton.setAttribute("class" , "bi bi-heart text-danger");
				}
			}
		};
		
		xmlhttp.open("get" , "./getMyLikeData.do?board_no=${data.boardVo.board_no}"); 
		xmlhttp.send();
	}
	
	function refreshTotalLike(){
		var xmlhttp = new XMLHttpRequest();
		
		xmlhttp.onreadystatechange = function(){
			if(xmlhttp.readyState==4 && xmlhttp.status==200){
				var data = JSON.parse(xmlhttp.responseText);
				
				//렌더링...
				var totalCountBox = document.getElementById("totalCountBox");
				totalCountBox.innerText = "총 좋아요수 : " + data.totalLikeCount;
			}
		};
		
		xmlhttp.open("get" , "./getTotalLikeCount.do?board_no=${data.boardVo.board_no}"); 
		xmlhttp.send();
	}
	
	function getSessionUserInfo(){
		var xmlhttp = new XMLHttpRequest();
		
		xmlhttp.onreadystatechange = function(){
			if(xmlhttp.readyState==4 && xmlhttp.status==200){
				var data = JSON.parse(xmlhttp.responseText);
				
				if(data.isLogined == true){
					logined = true;
					sessionNo = data.sessionNo;
				}else{
					logined = false;
				}
			}
		};
		
		xmlhttp.open("get" , "../member/getSessionUserInfo.do" , false); 
		xmlhttp.send();		
	}
	
function refreshCommentList(){
		
		var xmlhttp = new XMLHttpRequest();
		
		xmlhttp.onreadystatechange = function(){
			if(xmlhttp.readyState==4 && xmlhttp.status==200){
				var data = JSON.parse(xmlhttp.responseText);
				
				//렌더링...DOM 엘리먼트 컨트롤 : 생성 추가 삭제 접근... 속성...innerText등...
				
				var commentListBox = document.getElementById("commentListBox");
				
				//제한조건...innerHTML은...절대 쓰지 마셈...!!!!! 단 아래처럼 초기화 할때 빼고...
				commentListBox.innerHTML = ""; //초기화...
				
				for(commentData of data.commentlist){
					var rowBox = document.createElement("div"); //<div></div>
					rowBox.setAttribute("class" , "row"); //<div class='row'></div>
					
					var nickColBox = document.createElement("div");
					nickColBox.setAttribute("class" , "col-1 bg-primary");
					nickColBox.innerText = commentData.memberVo.member_nick; //<div class='col-2 bg-primary'>afef</div>
					
					//조립...
					rowBox.appendChild(nickColBox);
					
					var contentColBox = document.createElement("div");
					contentColBox.setAttribute("class" , "col-8 bg-info");
					contentColBox.innerText = commentData.commentVo.comment_content;
					
					rowBox.appendChild(contentColBox);
					
					var dateColBox = document.createElement("div");
					dateColBox.setAttribute("class" , "col-2 bg-secondary");
					dateColBox.innerText = commentData.commentVo.comment_writedate;
					
					rowBox.appendChild(dateColBox);
					
					//삭제 버튼...
					
					var deleteColBox = document.createElement("div");
					deleteColBox.setAttribute("class" , "col-1 bg-danger");
					
					if(sessionNo == commentData.memberVo.member_no){
						deleteColBox.setAttribute("onclick" , "deleteComment("+ commentData.commentVo.comment_no +")");
						deleteColBox.innerText = "X";
					}
										
					rowBox.appendChild(deleteColBox);
					
					commentListBox.appendChild(rowBox);
				}
				
			}
		};
		
		xmlhttp.open("get" , "./getCommentList.do?board_no=" + boardNo); 
		xmlhttp.send();		
		
	}

</head>
<body>
	<h1>제목 : ${data.boardVo.board_title }</h1>
	
	작성자 : ${data.memberVo.member_nick }<br>
	작성일 : ${data.boardVo.board_writedate }<br>
	조회수 : ${data.boardVo.board_readcount }<br>
	
	<c:forEach items="${data.imageVoList }" var="imageVo">
		<img src="/upload/${imageVo.image_link }"><br>
	</c:forEach>
	
	내용 : <br>
	${data.boardVo.board_content }<br>
	
	<br>
	
	<div>
		<i id="heartButton" class="bi bi-heart text-danger" onclick="like()"></i>
	</div>
	<div id="totalCountBox">총 좋아요 수 : ?
	</div>
	
	<!-- 댓글 -->
	<div>
	 댓글: <textarea id="abcd" rows="3" cols="60"></textarea>
	 <button onclick="writeComment()">작성</button>
	</div>
	
	<div id="commentListBox">
	<!--  
	  <div class="row">
	     <div class="col-2 bg-primary">한조</div>
	     <div class="col-8 bg-info">내용</div>
	     <div class="col-2 bg-secondary">21.5.7</div>
	     <div class="col-2 bg-danger" onclick='deleteComment()'></div>
	  </div>
	  -->
	</div>


	
	<a href="./mainPage.do">목록</a>
	<c:if test="${!empty sessionUser && sessionUser.member_no == data.boardVo.member_no}">	
	<a href="./deleteContentProcess.do?board_no=${data.boardVo.board_no }">삭제</a>
	<a href="./updateContentPage.do?board_no=${data.boardVo.board_no  }">수정</a>
	</c:if>
	
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>	
</body>
</html>